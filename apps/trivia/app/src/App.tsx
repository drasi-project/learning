import React, { useState } from 'react';
import './App.css';
import GameView from './game';
import axios from 'axios';
import config from "./config.json";
import { JoinGameDialog, SwitchTeamDialog, WelcomeDialog } from './joinGame';
import { Button, Stack } from '@mui/material';

function App() {

  const [joinOpen, setJoinOpen] = React.useState(true);
  const [welcomeOpen, setWelcomeOpen] = React.useState(false);
  const [switchOpen, setSwitchOpen] = React.useState(false);
  const [hasJoined, setHasJoined] = React.useState(false);
  const [teamName, setTeamName] = useState<string | null>(null);


  const [playerName, setPlayerName] = useState<string | null>(null);
  const [playerId, setPlayerId] = useState<string | null>(null);
  const [teamId, setTeamId] = useState<string | null>(null);

  const handleJoinClose = async (value: string) => {
    setJoinOpen(false);
    setTeamName(value);

    let res = await axios.post(`${config.api}/joinGame`, {
      teamName: value
    });

    setPlayerName(res.data.playerName);
    setTeamId(res.data.teamId);
    setPlayerId(res.data.playerId);
    setWelcomeOpen(true);
  };

  const handleWelcomeClose = async () => {
    setWelcomeOpen(false);
    setHasJoined(true);
  };

  const handleSwitchClose = async (value: string) => {
    setSwitchOpen(false);

    try {
      let res = await axios.post(`${config.api}/switchTeam`, {
        teamName: value,
        playerId: playerId
      });

      setTeamId(res.data.teamId);
      setTeamName(res.data.teamName);
    } catch (error) {
      console.error(error);
    }
  };

  if (playerId === null || !hasJoined) {
    return (
      <div className="App">
        <JoinGameDialog open={joinOpen} teamName={teamName ?? ''} onClose={handleJoinClose} />
        <WelcomeDialog open={welcomeOpen} teamName={teamName ?? ''} playerName={playerName ?? ''} onClose={handleWelcomeClose} />
      </div>
    );
  }

  const hanleSwitchOpen = () => {
    setSwitchOpen(true);
  }

  return (
    <div className="App">
      <SwitchTeamDialog open={switchOpen} teamName={teamName ?? ''} onClose={handleSwitchClose} />
      <div style={{ display: 'flex', flexDirection: 'column' }}>
        <header style={{ flex: 0, backgroundColor: '#f5f5f5', padding: '10px' }}>

          <Stack direction="row" spacing={2} >
            <h2 style={{ minWidth: '30%', float: 'left', textAlign: 'left' }}>Drasi Trivia Game</h2>
            <div>
              <h2>{playerName}</h2>
            </div>
            <div style={{ maxWidth: '180px', float: 'right', textAlign: 'right' }}>
              <div>
                <Stack direction="column">
                  <h3>{teamName}</h3>
                  <Button variant="outlined" style={{ marginLeft: '10px' }} onClick={hanleSwitchOpen}>Switch Team</Button>
                </Stack>
              </div>
            </div>
          </Stack>
        </header>
        <GameView playerId={playerId} playerName={playerName ?? ''} teamName={teamName ?? ''} teamId={teamId ?? ''} />
      </div>
    </div>
  );
}

export default App;
