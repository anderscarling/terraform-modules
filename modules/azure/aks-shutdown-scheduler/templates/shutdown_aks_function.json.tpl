{
  "bindings": [
    {
      "name": "myTimer",
      "type": "timerTrigger",
      "direction": "in",
      "schedule": "${cron_expression}"
    }
  ],
  "scriptFile": "../dist/ShutdownAKS/index.js"
}