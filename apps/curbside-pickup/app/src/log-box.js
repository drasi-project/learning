import React from 'react';
import {v4 as uuidv4} from 'uuid';
import { List, ListItem, ListItemText, Stack  } from '@mui/material';

var appendLog = log => {};

export function addLog(log) {  
  appendLog({ id: uuidv4(), ts: new Date(Date.now()), text: log });
}

export function LogBox() {
  const [logs, setLogs] = React.useState([]);
  
  appendLog = log => setLogs([log, ...logs]);

  return (
    <Stack>
      {logs.map(log =>
        <span key={log.id}>
          <b>[{log.ts.toLocaleTimeString()}]</b> {log.text}
        </span>
      )}      
    </Stack>
  );
}