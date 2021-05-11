#!/usr/bin/env dotnet-script

#r "nuget: System.CommandLine, 2.0.0-beta1.21216.1"
using System;
using System.CommandLine;
using System.CommandLine.Invocation;
using System.IO;
using System.Runtime.InteropServices;

//
// Console Parameter Handling
//
// var shellTitle = Console.Title;

// var rootCommand = new RootCommand
// {
//     new Option<string>(
//         "--title-option",
//         description: "Title to use for current shell")
// };

// rootCommand.Description = "ShellTitle Utility";

// // Note that the parameters of the handler method are matched according to the names of the options
// rootCommand.Handler = CommandHandler.Create<string>((titleOption) =>
// {
//     Console.WriteLine($"The requested title for the shell: {titleOption}");
//     shellTitle = titleOption;
// });

// // Parse the incoming args and invoke the handler
// var ignored = rootCommand.InvokeAsync(Args.ToArray()).Result;
// Console.WriteLine(shellTitle);
// // Set the shell title:
// Console.Title = shellTitle;
//Console.Out.WriteLine(@"\033]0;you@me:hi\007");
Process.Start(@"bash -c printf '\033]0;you@me:he\007'");