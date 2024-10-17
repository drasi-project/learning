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

import React from 'react';
import { ReactionResult } from 'react-reactive-graph';
import './game.css';
import Question from './question';
import CodeIcon from '@mui/icons-material/Code';
import config from "./config.json";
import { Button, Dialog, DialogActions, DialogContent, Paper, Stack, Table, TableBody, TableCell, TableContainer, TableHead, TableRow } from '@mui/material';
import Tabs from '@mui/material/Tabs';
import Tab from '@mui/material/Tab';

import Prism from 'prismjs/components/prism-core';
import { Highlight, themes } from "prism-react-renderer"
import "prismjs/components/prism-cypher";
//import "prismjs/components/prism-jsx";
import { TabContext, TabList, TabPanel } from '@mui/lab';

interface GameViewProps {
    playerId: string;
    playerName: string;
    teamName: string;
    teamId: string;
}

const GameView: React.FC<GameViewProps> = ({ playerId, playerName, teamName, teamId }) => {
    const [playerQueryOpen, setPlayerQueryOpen] = React.useState(false);
    const [teamQueryOpen, setTeamQueryOpen] = React.useState(false);
    const [inactiveQueryOpen, setInactiveQueryOpen] = React.useState(false);
   
    return (        
        <div className="container" >
            <div className="question-cell">
                <Question playerId={playerId} />
            </div>
            <div className="cell">
            <Stack spacing={1}>
                <h2>
                    Player Scoreboard
                    <Button size='small' onClick={() => setPlayerQueryOpen(true)} style={{ float: 'right'}}><CodeIcon/></Button>
                </h2>                
                <TableContainer component={Paper}>
                    <Table size="small" stickyHeader>
                    <TableHead>
                        <TableRow>
                        <TableCell sx={{ fontWeight: 'bold' }}>Player</TableCell>
                        <TableCell sx={{ fontWeight: 'bold' }}>Team</TableCell>
                        <TableCell sx={{ fontWeight: 'bold' }}>Correct</TableCell>
                        <TableCell sx={{ fontWeight: 'bold' }}>Incorrect</TableCell>
                        <TableCell sx={{ fontWeight: 'bold' }}>Skipped</TableCell>
                        <TableCell sx={{ fontWeight: 'bold' }}>Avg. Time</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        <ReactionResult
                            url={config.signalr}
                            queryId={config.playerScoresQueryId}
                            itemKey={(item: { PlayerName: any; }) => item.PlayerName}
                            sortBy='QuestionsCorrect' reverse>
                            <PlayerScoreTemplate />
                        </ReactionResult>
                    </TableBody>
                    </Table>
                </TableContainer>
            </Stack>                    
            
            </div>
            <div className="inactive-cell">
            <Stack>
                    <h2>
                        Inactive Players
                        <Button size='small' onClick={() => setInactiveQueryOpen(true)} style={{ float: 'right'}} ><CodeIcon/></Button>
                    </h2>
                    
                    <TableContainer component={Paper}>
                        <Table size="small" stickyHeader>
                        <TableHead>
                            <TableRow>
                                <TableCell sx={{ fontWeight: 'bold' }}>Player</TableCell>
                                <TableCell sx={{ fontWeight: 'bold' }}>Team</TableCell>
                                <TableCell sx={{ fontWeight: 'bold' }}>Inactive Since</TableCell>
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            <ReactionResult
                                url={config.signalr}
                                queryId={config.inactivePLayersQueryId}
                                itemKey={(item: any) => item.PlayerName}>
                                <InactiveTemplate />
                            </ReactionResult>
                        </TableBody>
                        </Table>
                    </TableContainer>
                </Stack>
            </div>
            <div className="cell">
                <Stack>
                    <h2>
                    Team Summary
                        <Button size='small' onClick={() => setTeamQueryOpen(true)} style={{ float: 'right'}} ><CodeIcon/></Button>
                    </h2>
                    <TableContainer component={Paper}>
                        <Table size="small" stickyHeader>
                        <TableHead>
                            <TableRow>
                            <TableCell sx={{ fontWeight: 'bold' }}>Team</TableCell>
                            <TableCell sx={{ fontWeight: 'bold' }}>Category</TableCell>
                            <TableCell sx={{ fontWeight: 'bold' }}>Correct</TableCell>
                            <TableCell sx={{ fontWeight: 'bold' }}>Incorrect</TableCell>
                            <TableCell sx={{ fontWeight: 'bold' }}>Skipped</TableCell>
                            <TableCell sx={{ fontWeight: 'bold' }}>Avg. Time</TableCell>
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            <ReactionResult
                                url={config.signalr}
                                queryId={config.teamScoresQueryId}
                                itemKey={(item: any) => item.TeamName + item.CategoryName}
                                sortBy='QuestionsCorrect' reverse>
                                <TeamScoreTemplate />
                            </ReactionResult>
                        </TableBody>
                        </Table>
                    </TableContainer>
                </Stack>
            </div>
            
            <Dialog id='player-query' open={playerQueryOpen} scroll='paper' fullWidth={false} maxWidth={'md'}>
                <QueryView query={playerScoresQuery} tsx={playersTsx} />
                <DialogActions>
                    <Button onClick={() => setPlayerQueryOpen(false)}>OK</Button>
                </DialogActions>
            </Dialog>

            <Dialog id='team-query' open={teamQueryOpen} scroll='paper' fullWidth={false} maxWidth={'md'}>
                <QueryView query={teamScoresQuery} tsx={teamsTsx} />
                <DialogActions>
                    <Button onClick={() => setTeamQueryOpen(false)}>OK</Button>
                </DialogActions>
            </Dialog>

            <Dialog id='inactive-query' open={inactiveQueryOpen} scroll='paper' fullWidth={false} maxWidth={'md'}>                
                <QueryView query={inactiveQuery} tsx={inactiveTsx} />                
                <DialogActions>
                    <Button onClick={() => setInactiveQueryOpen(false)}>OK</Button>
                </DialogActions>
            </Dialog>

        </div>        
    );
};

export default GameView;

const QueryView: React.FC<{query: string, tsx: string}> = ({ query, tsx }) => {

    const [tab, setTab] = React.useState("Query");

    const handleChange = (event: React.SyntheticEvent, newValue: string) => {
        setTab(newValue);
    };

    return (
        <TabContext value={tab}>
            <TabList onChange={handleChange}>
                <Tab label="Query" value="Query"/>
                <Tab label="UI" value="UI"/>
            </TabList>
            
            <TabPanel value="Query">
                <Highlight prism={Prism} theme={themes.oneLight} code={query} language="cypher">
                    {({ style, tokens, getLineProps, getTokenProps }) => (
                        <pre style={style}>
                            {tokens.map((line, i) => (
                            <div key={i} {...getLineProps({ line })}>                                
                                {line.map((token, key) => (
                                <span key={key} {...getTokenProps({ token })} />
                                ))}
                            </div>
                            ))}
                        </pre>
                        )}
                </Highlight>
            </TabPanel>
            <TabPanel value="UI">
                <Highlight theme={themes.oneLight} code={tsx} language="tsx">
                    {({ style, tokens, getLineProps, getTokenProps }) => (
                        <pre style={style}>
                            {tokens.map((line, i) => (
                            <div key={i} {...getLineProps({ line })}>                                
                                {line.map((token, key) => (
                                <span key={key} {...getTokenProps({ token })} />
                                ))}
                            </div>
                            ))}
                        </pre>
                        )}
                </Highlight>
            </TabPanel>
        </TabContext>
    );
}

function PlayerScoreTemplate(props: any) {
    return (
        <TableRow
            key={props.PlayerName}
            sx={{ '&:last-child td, &:last-child th': { border: 0 } }}>
            <TableCell>{props.PlayerName}</TableCell>
            <TableCell>{props.TeamName}</TableCell>
            <TableCell>{props.QuestionsCorrect}</TableCell>
            <TableCell>{props.QuestionsIncorrect}</TableCell>
            <TableCell>{props.QuestionsSkipped}</TableCell>
            <TableCell>{parseFloat(props.AverageDuration).toFixed(2)}</TableCell>
        </TableRow>
    );
}

function TeamScoreTemplate(props: any) {
    return (
        <TableRow
            key={props.TeamName + props.CategoryName}
            sx={{ '&:last-child td, &:last-child th': { border: 0 } }}>
            <TableCell>{props.TeamName}</TableCell>
            <TableCell>{props.CategoryName}</TableCell>
            <TableCell>{props.QuestionsCorrect}</TableCell>
            <TableCell>{props.QuestionsIncorrect}</TableCell>
            <TableCell>{props.QuestionsSkipped}</TableCell>
            <TableCell>{parseFloat(props.AverageDuration).toFixed(2)}</TableCell>
        </TableRow>           
          
    );
}

function InactiveTemplate(props: any) {
    return (
        <TableRow
            key={props.PlayerName}
            sx={{ '&:last-child td, &:last-child th': { border: 0 } }}>
            <TableCell>{props.PlayerName}</TableCell>
            <TableCell>{props.TeamName}</TableCell>
            <TableCell>{props.InactiveSince}</TableCell>        
        </TableRow>
    );
}

const playerScoresQuery = `MATCH
    (a:Answer)-[:ANSWER_FROM]->(p:Player)-[:MEMBER_OF]->(t:Team),
    (a:Answer)-[:ANSWER_TO]->(q:Question)
RETURN
    p.name AS PlayerName,
    t.name AS TeamName,
    
    avg(a.duration) as AverageDuration,
    
    count(CASE 
      WHEN a.answer = q.answer AND NOT a.skipped THEN 1 
      ELSE NULL 
    END) AS QuestionsCorrect,
    
    count(CASE 
      WHEN a.answer <> q.answer AND NOT a.skipped THEN 1 
      ELSE NULL 
    END) AS QuestionsIncorrect,

    count(CASE a.skipped 
      WHEN TRUE THEN 1 
      ELSE NULL 
    END) AS QuestionsSkipped`;

const teamScoresQuery = `MATCH
    (a:Answer)-[:ANSWER_FROM]->(p:Player)-[:MEMBER_OF]->(t:Team),
    (a:Answer)-[:ANSWER_TO]->(q:Question)-[:FROM_CATEGORY]->(c:Category)
RETURN
    t.name AS TeamName,
    c.name AS CategoryName,
    
    avg(a.duration) as AverageDuration,

    count(CASE 
      WHEN a.answer = q.answer AND NOT a.skipped THEN 1 
      ELSE NULL 
    END) AS QuestionsCorrect,
    
    count(CASE 
      WHEN a.answer <> q.answer AND NOT a.skipped THEN 1 
      ELSE NULL 
    END) AS QuestionsIncorrect,
    
    count(CASE a.skipped 
      WHEN TRUE THEN 1 
      ELSE NULL 
    END) AS QuestionsSkipped`;

    const inactiveQuery = `MATCH
    (a:Answer)-[:ANSWER_FROM]->(p:Player)-[:MEMBER_OF]->(t:Team)
WITH
    p,
    t,
    max(datetime({ epochMillis: a.time })) AS InactiveSince
WHERE
    InactiveSince <= datetime.realtime() - duration({ seconds: 30 })
OR
    drasi.trueLater(
        InactiveSince <= datetime.realtime() - duration({ seconds: 30 }), 
        InactiveSince + duration({ seconds: 30 }))
RETURN
    p.name AS PlayerName,
    t.name AS TeamName,
    InactiveSince`;

const playersTsx = `<ReactionResult 
    url={config.signalr} 
    queryId='player-scores' 
    itemKey={(item) => item.PlayerName}
        <PlayerScoreTemplate />
</ReactionResult>`;

const teamsTsx = `<ReactionResult 
    url={config.signalr} 
    queryId='team-scores'
    itemKey={(item) => item.TeamName}
        <TeamScoreTemplate />
</ReactionResult>`;

const inactiveTsx = `<ReactionResult 
    url={config.signalr} 
    queryId='inactive-players'
    itemKey={(item) => item.PlayerName}
        <InactiveTemplate />
</ReactionResult>`;
