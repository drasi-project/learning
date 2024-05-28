import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Button, Stack, RadioGroup, FormControl, FormControlLabel, CircularProgress, Radio, Snackbar, Alert } from '@mui/material';
import config from "./config.json";

interface QuestionData {
  id: number;
  category: string;
  question: string;
  answers: string[];
  correctAnswer: string;
}

interface QuestionProps {
    playerId: string;
}

const Question: React.FC<QuestionProps> = ({ playerId }) => {
  const [questionData, setQuestionData] = useState<QuestionData | null>(null);
  const [selectedAnswer, setSelectedAnswer] = useState<string | null>(null);
  const [startTime, setStartTime] = useState<Date | null>(null);
  const [correctOpen, setCorrectOpen] = useState<boolean>(false);
  const [incorrectOpen, setIncorrectOpen] = useState<boolean>(false);
  
  const calculateElapsedTime = () => {
    if (startTime !== null) {
        return Math.round((new Date().getTime() - startTime.getTime()) / 100) / 10;
    }
    return 0;
  }
  
  const [elapsedTime, setElapsedTime] = useState<number | undefined>(calculateElapsedTime());


  const fetchQuestion = () => {
    axios.get(`${config.api}/question`)
      .then(response => {
        setQuestionData(response.data);
        setStartTime(new Date());        
      });
  };

  useEffect(() => fetchQuestion(), []);
  useEffect(() => {
    setTimeout(() => {
        setElapsedTime(calculateElapsedTime());
    }, 110);
  });

  const handleAnswerChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setSelectedAnswer(event.target.value);
  };

  const handleSubmit = () => {
    if (selectedAnswer !== null && startTime !== null) {

      if (selectedAnswer === questionData?.correctAnswer) {
        setCorrectOpen(true);
        setTimeout(() => setCorrectOpen(false), 1500);
      } else {
        setIncorrectOpen(true);
        setTimeout(() => setIncorrectOpen(false), 1500);
      }      
      
      axios.post(`${config.api}/answer`, {
        answer: selectedAnswer,
        duration: elapsedTime,
        playerId,
        questionId: questionData?.id,        
        skipped: false    
      });

      setSelectedAnswer(null);
      setStartTime(null);
      setQuestionData(null);
      fetchQuestion();
    }
  };

  const handleSkip = () => {
    if (startTime !== null) {        
        axios.post(`${config.api}/answer`, {
            answer: null,
            duration: elapsedTime,
            playerId,
            questionId: questionData?.id,        
            skipped: true
        });
  
      setElapsedTime(0);  
      setSelectedAnswer(null);
      setStartTime(null);
      setQuestionData(null);
      fetchQuestion();
    }
  };

  if (!questionData) {
    return <CircularProgress />;
  }

  return (
    
    <div>
      <Stack direction="row" spacing={2}>        
        <h2 style={{ whiteSpace: 'nowrap' }}>{questionData?.category}</h2>
        <div style={{ float: 'right', textAlign: 'right' }}>{elapsedTime.toFixed(1)}</div>
      </Stack>
      
      <h3>{questionData?.question}</h3>
      
      <FormControl>
        <RadioGroup
            aria-labelledby="controlled-radio-buttons-group"
            name="controlled-radio-buttons-group"            
            onChange={handleAnswerChange}>
            {questionData?.answers.map((answer, index) => (
                <FormControlLabel key={answer} value={answer} control={<Radio />} label={answer} />                
            ))}            
        </RadioGroup>
        </FormControl>      
      
        <Stack direction="row" spacing={2}>
            <Button variant="contained" onClick={handleSkip}>Skip</Button>
            <Button variant="contained" onClick={handleSubmit}>Submit</Button>        
        </Stack>
        <Snackbar
          open={correctOpen} anchorOrigin={ {vertical: 'top', horizontal: 'left' } }>
            <Alert severity="success" variant="filled" sx={{ width: '30%', textAlign: 'left' }}>
              Correct
            </Alert>
        </Snackbar>
        <Snackbar
          open={incorrectOpen} anchorOrigin={ {vertical: 'top', horizontal: 'left' } }>
            <Alert severity="error" variant="filled" sx={{ width: '30%', textAlign: 'left' }}>
              Incorrect
            </Alert>
        </Snackbar>
    </div>
  );
};

export default Question;