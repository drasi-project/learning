/**
 * Copyright 2024 The Drasi Authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import * as React from 'react';
import Button from '@mui/material/Button';
import Avatar from '@mui/material/Avatar';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemAvatar from '@mui/material/ListItemAvatar';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import DialogTitle from '@mui/material/DialogTitle';
import Dialog from '@mui/material/Dialog';

import AddIcon from '@mui/icons-material/Add';
import { blue } from '@mui/material/colors';
import GroupAddIcon from '@mui/icons-material/GroupAdd';
import { DialogActions, DialogContent, DialogContentText, Stack } from '@mui/material';

const teams = ['Team A', 'Team B'];

export interface JoinGameDialogProps {
  open: boolean;
  teamName: string;
  onClose: (value: string) => void;
}

export function JoinGameDialog(props: JoinGameDialogProps) {
  const { onClose, teamName, open } = props;

  const handleClose = () => {
    onClose(teamName);
  };

  const handleListItemClick = (value: string) => {
    onClose(value);
  };

  return (
    <Dialog onClose={handleClose} open={open}>
      <DialogTitle>Choose a Team</DialogTitle>
      <List sx={{ pt: 0 }}>
        {teams.map((team) => (
          <ListItem disableGutters key={team}>
            <ListItemButton onClick={() => handleListItemClick(team)}>
                <Stack direction="row" spacing={2}>
                    <Avatar sx={{ bgcolor: blue[100], color: blue[600] }}>
                    <GroupAddIcon />
                    </Avatar>
                <ListItemText primary={team} sx={{ ml: -2 }} />
                </Stack>
            </ListItemButton>
          </ListItem>
        ))}        
      </List>
    </Dialog>
  );
}

export interface SwitchTeamDialogProps {
  open: boolean;
  teamName: string;
  onClose: (value: string) => void;
}

export function SwitchTeamDialog(props: SwitchTeamDialogProps) {
  const { onClose, teamName, open } = props;

  const handleClose = () => {
    onClose(teamName);
  };

  const handleListItemClick = (value: string) => {
    onClose(value);
  };

  return (
    <Dialog onClose={handleClose} open={open}>
      <DialogTitle>Choose a Team</DialogTitle>
      <List sx={{ pt: 0 }}>
        {teams.map((team) => (
          <ListItem disableGutters key={team}>
            <ListItemButton onClick={() => handleListItemClick(team)}>
                <Stack direction="row" spacing={2}>
                    <Avatar sx={{ bgcolor: blue[100], color: blue[600] }}>
                    <GroupAddIcon />
                    </Avatar>
                <ListItemText primary={team} sx={{ ml: -2 }} />
                </Stack>
            </ListItemButton>
          </ListItem>
        ))}        
      </List>
    </Dialog>
  );
}

export interface WelcomeDialogProps {
    open: boolean;
    teamName: string;
    playerName: string;
    onClose: () => void;
  }
  
  export function WelcomeDialog(props: WelcomeDialogProps) {
    const { onClose, teamName, playerName, open } = props;
  
    const handleClose = () => {
      onClose();
    };
  
  
    return (
      <Dialog onClose={handleClose} open={open}>
        <DialogTitle>Welcome</DialogTitle>
        <DialogContent>
          <DialogContentText id="alert-dialog-description">
            Welcome to <b>{teamName}</b>, your handle is <b>{playerName}</b>.
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleClose} autoFocus>
            OK
          </Button>
        </DialogActions>
        
      </Dialog>
    );
  }
  