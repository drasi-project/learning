# MVP Global Summit Live Drasi Demonstration - Setup (for Mac)

## Function Code
Change to ```apps/functions/```

Check ```local.settings```

Compile and run:

```
npm install
```


## App Code
Change to ```apps/app/```

Check ```config.json```

Compile and run:

```
npm install
```



## Local Cluster

Open a terminal and change to the  ```/apps/trivia/demo``` directory of the Drasi repo.

Create a local Kind cluster, install Drasi, install Drasi CLI, install secrets:

```
./setup-cluster
```

WILL ASK FOR SU PASSWORD



## Visual Studio Code Plugin

Install Drasi VS Code Extension as described in the docs:
https://project-drasi-docs.azurewebsites.net/solution-developer/vscode-extension/



## Display Setup
1. Screen 1
   1. Desktop 1 - PowerPoint: MVP Summit Deck Open 
   1. Desktop 2 - Edge Browser: Home Page
   1. Desktop 3 - VS Code apps/trivia folder
      1. Architecture Image
      1. API Image
      1. 
   1. Desktop 4 - 4 x Terminal
      1. Terminal: in apps/trivia/ folder
      1. Terminal: in apps/trivia folder
      1. Terminal: in apps/trivia/functions folder
      1. Terminal: in apps/trivia/app folder
1. Screen 2
   1.  VS Code - apps/trivia/demo folder

## File Settup

From apps/trivia:

```
code-insiders -n .
```


## Timings

1. Intro - 3 min
1. Drasi Deck - 12 min
1. UI Tour - 5 min
1. Install - 15 min
1. Outro - 3 min
1. Q & A - 10 min

Total: 48 min