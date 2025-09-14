# 🏗️ Style is Everything  
Clean Code, Beautiful Collaboration, and the AI Reviewer Era  
LWT Workshop 2025 — Hope Watson

---

## 📋 Prerequisites

Before you begin, make sure you have:

- [ ] GitHub account  
- [ ] LLM API key (Claude or equivalent)  
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
 - Ensure you are able to clone a github respository using SSH. It is best to use SSH since we will be making changes to the repository. If you don't have a `.ssh` already setup you will need to do that. 


## ⚙️ 1. Setup
Cloning Repo and Setting up Venv 

1. Open VSCode and open a `New Terminal`. 
2. Navigate to a directory you want to clone the git repository into. For your home directory use `cd ~`. 
3. Clone the workshop repository: 
    ```bash 
    git clone git@github.com:HopeMWatson/lwt-style-is-everything.git
    cd lwt-style-is-everything
    ```
4. Create virtual environment (venv):
    ```bash 
    bash setup-workshop.sh
    ```
    
    Give the venv script time to complete. 
5. Activate the venv
    ```bash
    source activate.sh
    ``` 
    
    We are now working inside of our local workshop venv. 

## 2. Run local data pipeline 
1. Install dbt project dependencies
    ```
    dbt deps
    ``` 
2. Execute entire pipeline including building tables, views, and running tests. 
3. Explatory data analysis on what we just built using duckdb. 

## 3. Read action code and learn its functions
1. Open `.github/workflows`.
2. You see the workflows and the controller file (more on this later).
3. Open up each of the actions and read over what they are doing and how they function.
    a. The PR size workflow ensure we do not add too many new files or new lines of code in a single PR.
    b. The file naming convention ensures we name files according to a prefix rule.
    c. The linting workflow enforces the rules we've specififed in our `.sqlfluff` file. Open up the `.sqlfluff file to look at the rulesets. This determines how our sql should be styled. 💅
    d. Our `dbt-ci-job` workflow builds only what has been modified and ensures our sql is actually valid to build the tables and views. Additionally, it runs all the data test checks. 
    e. AI reivewer `pr_ai_reviewer` summons claude via API key to review and comment on the PR. 
    f. Importantly, we want to specify the order in which these workflows run. For example, if our linting fails we want that to happen before we have to pay to use any tokens for Claude. 

There is a lot going on here and this the heart of this workshop, so take time to understand on your own time too! 

## 4. Trigger GitHub workflows for the first time 
1. Make a working branch:
    ``` git checkout -b working-branch```
    Double check you are in your working branch:
    ```git branch```
2. Open the SQL file `customers.sql` and make a dummy comment to commit, for example:
    ` -- dummy commment` 

    Note my spelling mistake of "comment" to "commment" is intentional. 
3. Save the change in the IDE.
4. Add and commit the change:
    ```git commit -am "dummy comment to view pipelines" 
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
