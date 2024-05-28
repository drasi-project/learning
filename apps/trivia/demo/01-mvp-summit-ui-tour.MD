# MVP Global Summit Live Drasi Demonstration - UI Tour

This is the Drasi Trivia Game Page

Header:
- Alias
- Team
- Switch Teams Button

Blue Panel - Top Left - Question Panel:
- Question + Category + Possible Answers
- Submit Answer or Skip
- Counter is measuring response time
- When you submit or skip, only write time, duration, and response 
- Once you start answering -> inactive -> evicted

Two White Panels - Right - Player and Team Scores
- Both very similar
- Both show Correct, Incorrect, Skipped, Average Response
- Player -> Player and Team
- Team -> Team and Category

Team Score -> Angle Brackets
- React: Query-driven UI: Build all our demo UIs 
  - SignalR
  - CQ ID
  - Item Template
- Continuous Query
  - Match
    - path crosses Sources
  - Aggregations
- Switch Team
  - Deletes Relation, Adds New
  - Same Team -> No Change

Bottom Left - Inactive Players
- After first question and 30s inactive
- After 300s you will be evicted
- Query
  - MATCH
    - smaller path
  - WITH
    - max - aggregate all connected answers -> InactiveSince
  - WHERE 
    - datetime.realtime
    - drasi.trueLater