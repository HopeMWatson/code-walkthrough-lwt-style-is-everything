# 🏗️ Style is Everything  
Clean Code, Beautiful Collaboration, and the AI Reviewer Era  
LWT Workshop 2025 — Hope Watson

---

## 📋 Materials You'll Need - Prerequisites 

Before you begin, make sure you have:

- [ ] GitHub account  
- [ ] Claude API key 
- [ ] Local IDE (VSCode recommended)  
- [ ] Ability to install software locally (DuckDB, dbt, SQLFluff)  

💡 *Tip: Use a personal account to avoid access/permission issues. Setup will run inside a `venv`, which you can delete afterward. The AI reviewer step costs ~$0.15 in Claude tokens.* 

---

## 🚀 Workshop Goals

By the end of this workshop, you will:

1. Learn **rules and AI-driven patterns** to clean up codebases  
2. Improve your **code review process** (for both newbies and veterans)  
3. Explore how to use **AI as a reviewer**, not just a generator  
4. Build confidence in **collaboration workflows** with CI/CD 

---

## Workshop Architecture 
 - TODO placeholder for diagram 

---

## 🗂️ Workshop Outline

We’ll go step by step:

1. **Setup** — Environment, repos, and installs  
2. Run local data pipeline 
3. Read action code 
4. Make SQL comment and trigger PR
5. Fix sqlfluff styling locally
6. Observe full pipeline and AI reviewer feedback
7. **Wrap-Up & Next Steps**

---

## 0. Addressing Prerequisites
 - Ensure you are able to clone a github respository using **SSH**. It is best to use SSH since we will be making changes to the repository. If you don't have a `.ssh` already setup you will need to do that. 
 - You will need a Claude API key. At the time of writing the Claude API requires separate credits from Pro subscription. Our workflow will cost approximately $0.12. To iterate on the pipeline I suggest $1.00 of API credits. 
 - The ability to install software. Many work computers do not allow downloads of software that are not from a trusted software center. For this reason I recommend using personal accounts for this workshop where possible. All software is installed in a venv that can be easily deleted following the workshop. 


## ⚙️ 1. Setup
### Cloning Repo to local 
1. Open VSCode and go to **Terminal** -> **New Terminal**. 
2. Navigate to a directory you want to clone the git repository into. For your home directory use `cd ~`. 
3. Clone the workshop repository: 
    ```bash 
    git clone git@github.com:HopeMWatson/lwt-style-is-everything.git code-walkthrough-lwt-style-is-everything
    cd code-walkthrough-lwt-style-is-everything
    ```

We now have our local repo. 
### Remote GitHub Repository 
We need to run our actions from GitHub which means we need to create a remote version of the repo. 
1. Go to github.com and make sure you are logged in.
2. Navigate to **Repositories** and create a new repo **New**. 
3. Name the repo `code-walkthrough-lwt-style-is-everything` and **Create repository**. 
CALLOUT: Before you get click happy don't use the code github suggests. This is because we are working from a cloned repo.
Notice that we have an empty repo. 

We have now created a remote repository. In our next step we need to link our local clone to remote. 

### Link local and remote repos
1. Make sure you are in your project directory:
```bash 
cd code-walkthrough-lwt-style-is-everything 
```
2. Set the remote so we link our local and remote. 
```bash 
git remote set-url origin git@github.com:HopeMWatson/code-walkthrough-lwt-style-is-everything.git
git push -u origin main
```
3. Head back to your repo on GitHub and refresh the webpage. Notice the entire project has been brought in and pushed to our remote repo! 

While we are still on GitHub let's get the Claude GitHub app installed. 

### Install Claude GitHub app 
The Claude GitHub app allows us to run Claude Code from your GitHub Pull Requests. If you already have it installed you are good to go, otherwise install the app using the next step. 
1. Navigate to Claude GitHub app, which can be found here https://github.com/apps/claude. 
2. **Install** and select user (if you have multiple users). 
3. Decide if you are okay with Claude app to work across *All repositories* or *Only select repositories*. I chose *All repositories*. 
4. **Install & Authorize**. 

### Activate local venv 
1. Navigate back to VSCode. 
2. Create virtual environment (venv):
    ```bash 
    bash setup-workshop.sh
    ```
Give the venv script time to complete. 
3. Activate the venv
    ```bash
    source activate.sh
    ``` 

## 2. Run local data pipeline 
1. Install dbt project dependencies
    ```bash 
    dbt deps
    ``` 
2. Execute entire pipeline including building tables, views, and running tests. 
```bash 
dbt build 
```
After running our `dbt build` you should see a file `workshop.duckdb` that was created. 
This is an enitre databse in a file -- duckdb is very cool; check it out at [duckdb.org](https://duckdb.org/)

3. Let's do some explatory data analysis on what we just built using duckdb. To boot up the duckdb CLI on our database use `duckdb workshop.duckdb`. 
4. See what commands are available to us type `.help` in the command line. 
5. Looks like we have some interesting commands such as `.tables` let's use that one to see the tables we built as part of our `dbt build`. \n 
Write `.tables` in the command line and enter. 
6. I'm interested in our `orders` table, let's take a closer look, type:
`select * from orders;` in the command line. 
7. Investigate one or two more tables on your own using the duckdb CLI. 
8. To quit the duckdb CLI write `.quit` in the command line. 

That brings us back to our directory. Now is a good time to take a look our project and pipelines. 

## 3. Read action code and learn its functions
1. Open `.github/workflows`.
2. You see the workflows and the controller file (more on this later).  
3. Open up each of the actions and read over what they are doing and how they function.<br>
   a. The PR size workflow ensure we do not add too many new files or new lines of code in a single PR.<br>
   b. The file naming convention ensures we name files according to a prefix rule.<br> 
   c. The linting workflow enforces the rules we've specififed in our `.sqlfluff` file. Open up the `.sqlfluff file to look at the rulesets. This determines how our sql should be styled. 💅<br>
   --TODO fix linebreak mess that looks sloppy when rendered 
   d. Our `dbt-ci-job` workflow builds only what has been modified and ensures our sql is actually valid to build the tables and views. Additionally, it runs all the data test checks.<br>
   e. AI reivewer `pr_ai_reviewer` summons claude via API key to review and comment on the PR.<br>
   f. Importantly, we want to specify the order in which these workflows run. For example, if our linting fails we want that to happen before we have to pay to use any tokens for Claude.<br>

There is a lot going on here and this the heart of this workshop, so take time to understand on your own time too! 

### Claude reviewer variable and Claude API key
#### Set GitHub variable for AI reviewewr
You saw in our `pr-pipeline-orchestrator` pipeline we use a variable `vars.ENABLE_AI_REVIEW == 'true'` as a switch to decide if we want the AI reviewer pipeline on. This can be helpful to control costs if you don't want the AI review pipeline running on every PR. 
1. In your GitHub repo go to **Settings**.
2. **Secrets and variables** -> **Actions** -> **Variables**.
3. **New repository variable**
4. **Name** the variable `ENABLE_AI_REVIEW` and set the **Value** to `true` and **Add variable**.
Our variable is set to allow our AI Reviewer pipeline to run. 

#### Claude API key
We need to create an Claude API to actually call Claude into our review process that we pass into a GitHub secret.
1. Go to [Claude Console](https://console.anthropic.com/dashboard) and click **Get API Key**. 
2. **Create Key**, select your workspace, and name your key; I named mine `code-walkthrough-lwt`. 
3. **Copy Key**. Note: in a production setting you may also place your key into another secrets manager software like AWS secrets manager or 1password. 
4. Go back to GitHub in your repo to **Settings**.
5. **Secrets and variables** -> **Actions** -> **New respository secret**.
6. **Name** the secret `ANTHROPIC_API_KEY` and copy in your **Secret** and finally **Add secret**. 

Now we have a way to securely Claude into our GitHub Actions. 

#### Generate dbt artifacts for "Production" deferral CI job
In this step we are simulating a production run to generate data and metadata for our CI job to defer to. 
Think of it as created both the code and data baseline state for CI to defer to! 

I admit, state and tracking state can be a very complex topic outside the scope of this workshop. 
What I will say is take time to think about how often the state of code changes. When you change the logic of your code the effects data, you then want your data pipeline to run again to reflect those changes. 

1. In our `code-walkthrough-lwt-style-is-everything` repo go to **Actions**. 
2. Select the `main-state-build` action. 
3. Click **Run workflow** to manually trigger the workflow off the `main` branch. 
4. The workflow will kick off an take about a 45 seconds to complete.
Note in the step `Full build on main` we run all 47 seeds, models, and tests. Keep this number in mind when we run the CI pipeline.
5. After the workflow is complete look at **Artifacts**. Both `dbt-state-artifacts` and `workshop.db` were created. 
What are these artifacts doing? Respectively `dbt-state-artifacts` is tracking the state of our code and `workshop.db` is tracking the state of our data. 

Why did we do this?
Now when we run a CI job, we only have to create what we changed and downstream impacts of the change instead of rerunning everything.  

## 4. Trigger GitHub workflows for the first time 
1. Make a working branch:
    ``` git checkout -b working-branch```
    Double check you are in your working branch:
    ```git branch```
2. Open the SQL file `locations.sql` and replace the `*` with the actual column names. Please leave out `opened_date` on purpose! 
    ```sql
    location_id,
    location_name, 
    tax_rate
    ```
3. Save the change in the VSCode.
4. Check your git status using `git status` to ensure the modification was just tracked. 
5. Add and commit the change:
    ```git commit -am "explicit naming of locations columns" ```
6. Push your changes using `git push --set-upstream origin working-branch`. 

- Before we move on can you guess workflow(s) of the four workflows will fail: pr size, file naming, sqlfluff, and dbt build? Ignore AI reviewer pipeline for now. 

7. Navigate to GitHub and **Pull requests** -> **New pull request** and select `working-branch` and **Create pull request**. 
8. Select **Create pull request** again. 
9. You will now see our `PR Pipeline Orchestrator` kickoff. 

## 5. Investigating the PR Pipeline Orchestrator Results.
1. First up is our PR size check, how did we do:
```
🔍 Checking PR size limits...
📁 Files changed: 1
📊 Lines added: 5
📊 Lines removed: 1
📊 Net lines: 4
✅ PR size is within limits
📋 Summary:
  - Files: 1/100
  - Lines added: 5/10,000
```
We definitely passed this!

2. How about File naming conventions:
``` 
✅ All model and YAML filenames follow conventions.
```
Looks great! 

3. Linting 
Oof -- not so much. We have some trailing whitespace and ugly sql. 
We failed this step, but we allowed `continue on error` so it did not halt our entire pipeline! 

4. How about our dbt CI build? 
Firstly, our CI pass checks which means if we did promote this change to production it would not break out pipelines. 

Additionally, note how only the changed model was run instead of all 47 models. Since `locations` has no downstream impact on another model, it is the only one run. 
```
1 of 1 START sql table model main.locations .................................... [RUN]
1 of 1 OK created sql table model main.locations ............................... [OK in 0.11s]
```

5. Finally, what is our AI review telling us? 
Claude took a minute and $0.15 to review all of our code.
    1. Go to **Pull requests** and see where Claude has added comments to our code!
    2. Claude flagged a *Potential Data Loss* by excluding the column `opened_date` and asks us to add it back in or add a comment in the SQL as to exactly why we are leaving it out. 
    3. Claude is also praising us for using explicit column naming instead of implicit for clarity! 

Claude caught an issue that could happen in the real world -- a developer accidentally omits a column that impacts the schema of a table used for reporting and breaks it. 

GitHub also sent us an email with our Claude summary -- I think this is cool, but if you find it noisy you could disable the emails. 

## 6. (Optional) Turn off `ENABLE_AI_REVIEW` 
We don't need our AI Reviewer step on to clean up our SQL styling to fix our linting step. 

1. Head back to your GitHub repo settings and variable. 
2. Change the value of `ENABLE_AI_REVIEW` to `false`.
3. This will prompt verification code sent to your email. 

Our AI Reviewer step will now be skipped! 

## 7. Fixing linting errors locally
We have to fix our ugly code! 

1. Go back VSCode to your working branch and ensure you have a clean branch:
    ```git checkout working-branch```
    ``` git status``(ensure it's up to date)
2. 
-- TODO placeholder for sqlfluff changes and then committing  


## 8. Recapping, Next Steps, and Cleanup
### Recapping


### Next Steps 

### Cleanup 
Now for the cleanup and teardown. 
If you don't want this repository on your computer or GitHub following the workshop here are the instructions. 

#### Local cleanup 
1. For local cleanup navigate the the directory in your terminal. We can wildcard it to find it regardless of the directory you cloned into:
    ```bash 
    cd *lwt-style-is-everything*
    ```
2. *Only run this if you want the entire repository deleted:*
    ```bash 
    rm -rf lwt-style-is-everything
    ```    
#### Remote GitHub cleanup 
1. Navgiate to the *Settings* area of your repository.
2. Head on down to the end of the page to the *Danger Zone*
3. Select *Delete this repository*. 

# Instructor notes 
1. To ensure I don't overwrite my authored workshop give the repo a different name. 
```bash 
git clone git@github.com:HopeMWatson/lwt-style-is-everything.git code-walkthrough-lwt-style-is-everything
```


# Contributing to this repository 
This is a workshop repository, so usually that means it is narrowly scoped and rarely iterated on by contributors.
However, I welcome feedback, suggestions, and opening issues! 

One aspect of this workshop I didn't have time to address is Windows friendly instructions; it is written for MacOS and linux. 
If you want to make this workshop Windows friendly please feel free to contribute. 

# Acknowledgements 
Firstly, I have to thank the dbt Labs teams since I'm building on prior art from the long lived jaffle shop. 
Special thank you to all the contributors there I've personally worked with over the years -- Winnie, Anders, and Benoit. 

Secondly, to my partner Nicole, that both encourages and tolerates (in that order) my work and my endless learning (with a cupful of perfectionism). 

