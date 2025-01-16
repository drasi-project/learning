# Getting Started with Drasi
Follow the tutorial [instructions here](https://drasi.io/getting-started/).

### Steps for running in VS Code with a Dev Container
1. Open this directory in Visual Studio Code
2. Open the Command Palette by typing `Ctrl + Shift + P` (windows) or `Cmd + Shift + P` (mac)
3. Type 'dev containers:'
4. Select 'Dev Containers: Rebuild and Reopen in Container'


------


```sql
insert into "RiskyImage" ("Id", "Image", "Reason") values (101, 'drasidemo.azurecr.io/my-app:0.2', 'Critical Bug')
```



```shell
kubectl set image pod/my-app-2 app=drasidemo.azurecr.io/my-app:0.3
```