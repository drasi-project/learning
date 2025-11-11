using System;
using System.Text;
using System.Linq;
using Qdrant.Client;
using Qdrant.Client.Grpc;
using Microsoft.Extensions.Configuration;
using DotNetEnv;
using Spectre.Console;
using Azure.AI.OpenAI;
using Azure;

// Load environment variables
Env.Load();

// Build configuration
var configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: true)
    .AddEnvironmentVariables()
    .Build();

// Get configuration values
var azureOpenAIEndpoint = configuration["AZURE_OPENAI_ENDPOINT"] ?? 
    throw new InvalidOperationException("AZURE_OPENAI_ENDPOINT not configured");
var azureOpenAIKey = configuration["AZURE_OPENAI_API_KEY"] ?? 
    throw new InvalidOperationException("AZURE_OPENAI_API_KEY not configured");
var chatDeploymentName = configuration["AZURE_OPENAI_CHAT_DEPLOYMENT"] ?? "gpt-4";
var embeddingDeploymentName = configuration["AZURE_OPENAI_EMBEDDING_DEPLOYMENT"] ?? "text-embedding-3-large";
var qdrantHost = configuration["QDRANT_HOST"] ?? "localhost";
var qdrantPort = int.Parse(configuration["QDRANT_PORT"] ?? "6334");
var collectionName = configuration["QDRANT_COLLECTION"] ?? "product_knowledge";

// Theme configuration
var terminalTheme = configuration["TERMINAL_THEME"]?.ToLower() ?? "dark";
bool isLightTheme = terminalTheme == "light";

// Define theme-aware colors
var primaryColor = isLightTheme ? "darkblue" : "blue";
var secondaryColor = isLightTheme ? "navy" : "blue";
var warningColor = isLightTheme ? "darkorange" : "yellow";
var successColor = isLightTheme ? "darkgreen" : "green";
var errorColor = isLightTheme ? "darkred" : "red";
var infoColor = isLightTheme ? "darkblue" : "cyan";
var mutedColor = isLightTheme ? "grey" : "dim";
var titleColor = isLightTheme ? "bold darkblue" : "bold yellow";

// Helper function to get Color enum from string
Color GetColorEnum(string colorName)
{
    return colorName.ToLower() switch
    {
        "darkblue" => Color.DarkBlue,
        "navy" => Color.Navy,
        "blue" => Color.Blue,
        "darkgreen" => Color.Green4,
        "green" => Color.Green,
        _ => Color.Blue
    };
}

// Display startup banner
AnsiConsole.Write(
    new FigletText("Drasi RAG Demo")
        .Centered()
        .Color(GetColorEnum(secondaryColor)));

AnsiConsole.MarkupLine($"[{titleColor}]Product Knowledge Assistant powered by Drasi[/]");
AnsiConsole.MarkupLine($"[{mutedColor}]Real-time vector store synchronization with multi-source data[/]");

AnsiConsole.WriteLine();

// Initialize Azure OpenAI client
var openAiClient = new AzureOpenAIClient(
    new Uri(azureOpenAIEndpoint),
    new AzureKeyCredential(azureOpenAIKey));

// Initialize Qdrant client
var qdrantClient = new QdrantClient(qdrantHost, qdrantPort, false);

// Test Qdrant connection
try
{
    AnsiConsole.Status()
        .Spinner(Spinner.Known.Star)
        .SpinnerStyle(Style.Parse(primaryColor))
        .Start("Connecting to Qdrant...", ctx =>
        {
            var collections = qdrantClient.ListCollectionsAsync().Result;
            ctx.Status($"Connected to Qdrant at {qdrantHost}:{qdrantPort}");
        });
    
    AnsiConsole.MarkupLine($"[{successColor}]✓[/] Connected to Qdrant at [{infoColor}]{qdrantHost}:{qdrantPort}[/]");
}
catch (Exception ex)
{
    AnsiConsole.MarkupLine($"[{errorColor}]✗[/] Failed to connect to Qdrant: {{0}}", ex.Message);
    AnsiConsole.MarkupLine($"[{warningColor}]Make sure Qdrant is running and accessible[/]");
    return;
}

// Helper function to search in Qdrant
async Task<List<(string text, float score, Dictionary<string, object> metadata)>> SearchQdrant(string query, int limit = 3)
{
    var results = new List<(string text, float score, Dictionary<string, object> metadata)>();
    
    try
    {
        // Check if collection exists
        var collections = await qdrantClient.ListCollectionsAsync();
        if (!collections.Contains(collectionName))
        {
            AnsiConsole.MarkupLine($"[{warningColor}]Collection '{collectionName}' does not exist yet. Data may still be syncing.[/]");
            return results;
        }
        
        // Generate embedding for the query
        var embeddingResponse = await openAiClient.GetEmbeddingClient(embeddingDeploymentName)
            .GenerateEmbeddingAsync(query);
        var queryVector = embeddingResponse.Value.ToFloats().ToArray();
        
        // Search in Qdrant
        var searchResult = await qdrantClient.SearchAsync(
            collectionName,
            queryVector,
            limit: (ulong)limit);
        
        foreach (var point in searchResult)
        {
            var content = point.Payload.ContainsKey("content") ? 
                point.Payload["content"].StringValue : "No content";
            var title = point.Payload.ContainsKey("title") ? 
                point.Payload["title"].StringValue : "No title";
            
            var metadata = new Dictionary<string, object>();
            foreach (var kvp in point.Payload)
            {
                metadata[kvp.Key] = kvp.Value.HasStringValue ? kvp.Value.StringValue : kvp.Value.ToString();
            }
            
            results.Add((content, point.Score, metadata));
        }
    }
    catch (Exception ex)
    {
        AnsiConsole.MarkupLine($"[{errorColor}]Error searching Qdrant:[/] {{0}}", ex.Message);
    }
    
    return results;
}

// RAG query function
async Task<string> AskAboutProducts(string question)
{
    try
    {
        // Search for relevant products
        var searchResults = await SearchQdrant(question, 3);
        
        if (searchResults.Count == 0)
        {
            return "I don't have any information about that in my knowledge base. The data might still be syncing from Drasi.";
        }
        
        // Build context from search results
        var context = new StringBuilder();
        foreach (var (text, score, metadata) in searchResults)
        {
            context.AppendLine(text);
            context.AppendLine("\n---\n");
        }
        
        // Create prompt
        var prompt = $@"You are a helpful product expert assistant. Based on the following product information 
including technical specifications and real customer feedback, answer the user's question.
Be specific and cite customer reviews when relevant. Be concise but informative.

Context:
{context}

Question: {question}

Answer:";
        
        // Get completion from Azure OpenAI
        var chatClient = openAiClient.GetChatClient(chatDeploymentName);
        var response = await chatClient.CompleteChatAsync(prompt);
        
        var answer = response.Value.Content[0].Text;
        
        // Display sources
        AnsiConsole.WriteLine();
        AnsiConsole.MarkupLine($"[{mutedColor}]Based on {{0}} relevant sources (relevance scores: {{1}})[/]", 
            searchResults.Count,
            string.Join(", ", searchResults.Select(s => $"{s.score:F2}")));
        
        return answer;
    }
    catch (Exception ex)
    {
        return $"Error generating response: {ex.Message}";
    }
}

// Sample questions for quick access
var sampleQuestions = new[]
{
    "What laptop options do you have?",
    "Which products have the best ratings?",
    "What do customers say about the products?",
    "Show me products under $500",
    "What are the available product categories?",
    "Tell me about the most expensive products",
    "Which products have 5-star ratings?",
    "What wireless products are available?",
    "Show me the latest products",
    "What do you have in stock?"
};

// Main interaction loop
AnsiConsole.WriteLine();
AnsiConsole.Write(new Rule($"[{primaryColor}]Ready to Answer Questions[/]"));
AnsiConsole.WriteLine();

while (true)
{
    // Show menu
    var choice = AnsiConsole.Prompt(
        new SelectionPrompt<string>()
            .Title($"[{successColor}]What would you like to do?[/]")
            .AddChoices(new[] { 
                "Ask a custom question",
                "Use a sample question",
                "Check vector store status",
                "Exit"
            }));

    if (choice == "Exit")
    {
        break;
    }

    string question = "";
    
    if (choice == "Ask a custom question")
    {
        question = AnsiConsole.Ask<string>($"[{infoColor}]Your question:[/]");
    }
    else if (choice == "Use a sample question")
    {
        question = AnsiConsole.Prompt(
            new SelectionPrompt<string>()
                .Title($"[{successColor}]Select a sample question:[/]")
                .AddChoices(sampleQuestions));
    }
    else if (choice == "Check vector store status")
    {
        await AnsiConsole.Status()
            .Spinner(Spinner.Known.Star)
            .SpinnerStyle(Style.Parse(primaryColor))
            .StartAsync("Checking vector store...", async ctx =>
            {
                try
                {
                    // Check collections
                    var collections = await qdrantClient.ListCollectionsAsync();
                    
                    AnsiConsole.WriteLine();
                    AnsiConsole.MarkupLine("[bold]Vector Store Status:[/]");
                    AnsiConsole.MarkupLine($"  Host: [{infoColor}]{qdrantHost}:{qdrantPort}[/]");
                    AnsiConsole.MarkupLine($"  Collections: [{successColor}]{collections.Count()}[/]");
                    
                    if (collections.Contains(collectionName))
                    {
                        AnsiConsole.MarkupLine($"  Target collection '[{infoColor}]{collectionName}[/]': [{successColor}]EXISTS[/]");
                        
                        // Get collection info
                        var collectionInfo = await qdrantClient.GetCollectionInfoAsync(collectionName);
                        AnsiConsole.MarkupLine($"  Points count: [{successColor}]{collectionInfo.PointsCount}[/]");
                        AnsiConsole.MarkupLine($"  Vectors count: [{successColor}]{collectionInfo.IndexedVectorsCount}[/]");
                    }
                    else
                    {
                        AnsiConsole.MarkupLine($"  Target collection '[{infoColor}]{collectionName}[/]': [{warningColor}]NOT FOUND[/]");
                        AnsiConsole.MarkupLine($"  [{mutedColor}]The collection will be created when Drasi syncs data[/]");
                    }
                }
                catch (Exception ex)
                {
                    AnsiConsole.MarkupLine($"[{errorColor}]Error checking status:[/] {{0}}", ex.Message);
                }
            });
        
        AnsiConsole.WriteLine();
        continue;
    }

    if (!string.IsNullOrWhiteSpace(question))
    {
        AnsiConsole.WriteLine();
        AnsiConsole.MarkupLine("[bold]Question:[/] {0}", question);
        AnsiConsole.WriteLine();

        await AnsiConsole.Status()
            .Spinner(Spinner.Known.Star)
            .SpinnerStyle(Style.Parse(primaryColor))
            .StartAsync("Searching knowledge base...", async ctx =>
            {
                var answer = await AskAboutProducts(question);
                
                // Display answer
                var panel = new Panel(answer)
                {
                    Header = new PanelHeader(" Answer ", Justify.Center),
                    Border = BoxBorder.Rounded,
                    BorderStyle = new Style(isLightTheme ? Color.Green4 : Color.Green),
                    Padding = new Padding(2, 1)
                };
                AnsiConsole.Write(panel);
            });
    }
    
    AnsiConsole.WriteLine();
    AnsiConsole.Write(new Rule());
    AnsiConsole.WriteLine();
}

// Farewell
AnsiConsole.WriteLine();
var goodbye = new Panel($"[{titleColor}]Thank you for using Drasi RAG Demo![/]\n[{mutedColor}]Real-time knowledge powered by continuous queries[/]")
{
    Border = BoxBorder.Double,
    BorderStyle = new Style(GetColorEnum(secondaryColor)),
    Padding = new Padding(2, 1)
};
AnsiConsole.Write(goodbye);