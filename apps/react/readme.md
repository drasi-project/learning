# Reactive Graph React Components

## Installation

Add as a dependency to your package.json

```json
{
    "dependencies": {
    "react-reactive-graph": "file:../path to react-reactive-graph library"
  }
}
```

Run `npm install` to setup a symlink

## Usage

```javascript
import { ReactionResult } from 'react-reactive-graph';

const ItemTemplate = props => <tr><td>{props.EmployeeName}</td><td>{props.ManagerName}</td><td>{props.IncidentDescription}</td></tr>

function App() {
  return (
    <div className="App">      
      <table>
        <thead>
          <tr><th>Employee</th><th>Manager</th><th>Incident</th></tr>
        </thead>
        <tbody>
        <ReactionResult 
            url="https://reactive-graph-proxy.azurewebsites.net/api"
            queryId="query1"
            itemKey={item => item.EmployeeName + item.IncidentDescription}
            onMessage={ItemTemplate} />
        </tbody>
      </table>
    </div>
  );
}
```
