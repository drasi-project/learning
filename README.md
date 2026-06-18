# Learning about Drasi
This repo contains code for a tutorial and a few sample applications that use Drasi as an end-to-end solution for change detection and real-time reactions. The tutorial The applications will help you understand how to implement and deploy Drasi for different scenarios. Each app folder within this repo has a README.md which details what the scenario for the app, code for the apps, requisite test data, and how to run the samples.

## Getting Started with Drasi
#### Detect and react to your first database change using Drasi
[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/drasi-project/learning)

[The step-by-step tutorial linked here](https://drasi.io/drasi-server/getting-started/) will help you get Drasi up and running quickly and show you how easy it is to create Sources, Continuous Queries, and Reactions.

## Tutorials
Step-by-step guided tutorials for learning Drasi:
1. [Getting Started](tutorial/getting-started) - Getting started with Drasi setup instructions for GitHub Codespaces and VS Code Dev Containers.
2. [Building Comfort](tutorial/building-comfort) - Drasi for a building management scenario with real-time change detection.
3. [Curbside Pickup](tutorial/curbside-pickup) - Drasi for correlating changes across multiple databases in a real-time curbside pickup scenario.
4. [Dapr](tutorial/dapr) - Drasi for supercharging Dapr applications with real-time data change processing across multiple microservices.
5. [Absence of Change](tutorial/absence-of-change) - Drasi's abilities to trigger alerts when events do not occur within a stipulated time window.
6. [Risky Containers](tutorial/risky-containers) - Detecting risky containers using Drasi.

## Sample Applications
Following sample applications demonstrate usage of Drasi in different scenarios:
1. [Fleet POC](apps/fleet-poc) - Drasi for an efficient solution to translate vehicle telemetry into actionable insights for Connected Fleet scenarios.
2. [Non-events](apps/non-events) - An app to demonstrate Drasi's abilities to trigger alerts when events do not occur within a stipulated time window.
3. [Trivia](apps/trivia) - A trivia game app with dashboards that are updated directly by Drasi when team and player scores change or when players are inactive for a period of time.
4. [RAG Chat App](apps/rag-chat-app) - A demonstration of how Drasi's continuous queries maintain a real-time vector store for RAG applications.
5. [React Components](apps/react) - Reactive Graph React components for use with Drasi.