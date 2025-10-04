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

💡 *Tip: Use a personal account to avoid access/permission issues. Setup will run inside a `venv`, which you can delete afterward. The AI reviewer step costs ~0.12¢ in Claude tokens.* 

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

## 4. Trigger GitHub workflows for the first time 
1. Make a working branch:
    ``` git checkout -b working-branch```
    Double check you are in your working branch:
    ```git branch```
2. Open the SQL file `customers.sql` and make a dummy comment to commit, for example:
    ` -- dummy commment` 

    Note my spelling mistake of "comment" to "commment" is intentional. 
3. Save the change in the VSCode.
4. Add and commit the change:
    ```git commit -am "dummy comment to view pipelines" ```
5. Before we move on can you guess workflow(s) of the four workflows will fail: pr size, file naming, sqlfluff, and dbt build? Ignore AI reviewer pipeline for now. 

## 5. Investigate pipelines on GitHub 
1. Review pipeline runs and address errors. 
2. We should see errors both on file naming and sqlfluff. 
3. Note how the AI reviewer pipeline was blocked! 
4. It's time to resolve the style issues we have locally, commit those changes, and re-trigger our pipelines with the new commit. 


## 6. Fixing errors locally
### Naming Conventions 
1. Stepping back, our naming convention for marts doesn't actually seem fit for purpose. Let's quickly make a separate branch to take that logic out and make a small PR to merge into `main` to update the naming convention pipeline logic. In reality this is an adjustment you would talk to your team and the business about first. 

-- TODO add more step by step points here. 

### sqlfluff
1. Go back to your working branch and ensure you have a clean branch:
    ```git checkout working-branch```
    ``` git status``(ensure it's up to date)
2. 
-- TODO placeholder for sqlfluff changes and then committing  


## 7. Recapping, Next Steps, and Cleanup
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

