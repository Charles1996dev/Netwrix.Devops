var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHealthChecks();

var app = builder.Build();

app.MapGet("/", () => Results.Ok(new
{
    app = "Netwrix.DevOps.Test.App",
    status = "ok",
    utc = DateTimeOffset.UtcNow
}));

app.MapHealthChecks("/health");

app.Run();

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHealthChecks();

var app = builder.Build();

app.MapGet("/", () => Results.Ok(new
{
    app = "Netwrix.DevOps.Test.App",
    status = "ok",
    utc = DateTimeOffset.UtcNow
}));

app.MapHealthChecks("/health");

app.Run();

