Background:
    - We are working on a new project called Drasi.
    - Drasi runs on Kubernetes and has its own Drasi CLI. It does not use Kubectl.
    - For completely new users, we've written a tutorial.
    - The tutorials are for complete beginners to Drasi, to try Drasi hands-on.

Environment:
    - You are already placed inside a devcontainer environment setup mentioned in the documentation.
    - This environment has Playwright and Chromium pre-installed globally. The NODE_PATH is already configured to include global modules. You can require('playwright') directly in your Node.js scripts without running 'npm install'.
    - Since you are running inside the devcontainer environment, you won't need to setup additional port-forwarding - localhost should work.
    

Tutorial Docs:
    - Follow the tutorial documentation at @tutorial-docs/_index.md .
    - All the screenshots referenced in this doc are also in the same directory @tutorial-docs/ .
    - At the end of the tutorial you must write a final markdown report indicating success or failure. This should reflect if a new human user can follow the instructions without getting confused.

Goal:
    - You are an agent that will act like a new human user to Drasi and follow through the tutorial step by step.
    - At each step evaluate if the instructions or the expected output (or effect or change) mentioned in the tutorial is ambiguous for you (or a human) or not.
    - After each step compare the output you see with the expected output.
    - Write a final report that includes a success/fail metric indicating if you were able to follow through all the steps in the tutorial successfully.

Evaluation Criteria:
    - For CLI commands, the output may not match exactly character by character. We can ignore whitespace and fields like timestamp or GUIDs which can change between runs. But core data and status fields must match the expectation. For example, a Drasi source name and its status.
    - For steps involving webpages, you can use Playwright to open them in browser and perform navigation, clicking, etc. mimicking user behavior. You can then take screenshots using Playwright and compare them to the screenshot shared in the tutorial documentation. When comparing images, we are not looking for pixel-by-pixel comparison. Rather we're looking for semantic match - the core data fields like Names, numeric values, number of rows, etc. should match. Some fields that change on each run like GUIDs or Timestamps may not match and that is fine.
    - Tutorial instructions must be unambiguous for any agent or human.
    - The sequence of instructions must be unambiguous for any agent or human.
    - The tutorial instructions should not have assumptions that are not expressed clearly.

Output Details:
    - All output must go into a folder named `evaluation-` suffixed with timestamp of start of this run. Create this at the start.
    - All screenshots taken by playwright must have two digit and underscore as prefix in their name. For example - `01_my-screenshot.png`. The numbers will keep incrementing, keeping the screenshots taken in order.
    - Output of any CLI command that is considered during evaluation must also be copied to a text file. These files must have two digit and underscore as prefix in their name. For example - `01_list-sources.txt'.
    - A single final file `report.md` must be generated at the end in the evaluation directory.
        ○ CRITICAL: The STATUS line must appear EXACTLY ONCE in the entire report. Write `## STATUS: SUCCESS` or `## STATUS: FAILURE` only at the END of the report, NEVER per step.
        ○ Do NOT write "STATUS: SUCCESS" or "STATUS: FAILURE" for individual steps. Use other words like "Step passed", "Step failed", "Verified", etc. for per-step results.
        ○ Rest of the file can explain why the tutorial has failed evaluation or succeeded.
        ○ For each step of the tutorial you follow and evaluate, you can add a section to this markdown file.
        ○ You can reference the text files or the screenshots taken for evaluation.
        ○ Document the successful or failed evaluations in the report for each step using words other than STATUS.

Skip Directives:
    - Some tutorial sections are marked optional and should be skipped during evaluation.
    - Format: `<!-- drasi-eval-skip-start id="<id>" reason="<reason>" -->` ... `<!-- drasi-eval-skip-end id="<id>" -->`
    - Skip all content between matching start/end markers. Do not execute commands or verify outputs within.
    - In your report, list each skipped section by id and include the reason verbatim.

Constraints:
    - You must run only the Drasi or Kubernetes commands explicitly specified in the tutorial doc for devcontainer environment.
    - You must not run any extra port forwards, as everything should be setup in the devcontainer for you already. If something is not working, terminate the evaluation immediately and mark it as failed.
    - If something is broken, terminate the evaluation immediately and mark it as failed.
    - If any instruction is not clear or ambiguous, terminate the evaluation immediately and mark it as failed.
    - If you run into a situation where there is a mismatch with expected output or environment behaviors, terminate the evaluation immediately and mark it as failed.
    - You must not debug failures or Fix anything. Upon hitting any failure, terminate the evaluation immediately and mark it as failed.
    - Do not perform any Drasi or Kubernetes related cleanup steps post completion if mentioned in tutorial docs.
    - Whatever scripts you write or modules you install must remain within the evaluation directory you create at the start of the task.

Final Checklist (complete these before ending):
    1. Ensure `report.md` exists in the evaluation directory.
    2. Verify that `report.md` ends with EXACTLY ONE line: `## STATUS: SUCCESS` or `## STATUS: FAILURE`.
    3. Verify you have NOT written "STATUS: SUCCESS" or "STATUS: FAILURE" anywhere else in the report.