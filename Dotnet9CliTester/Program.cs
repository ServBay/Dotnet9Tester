using System;
using System.Runtime.InteropServices;

namespace Dotnet9CliTester;

// This program tests the availability of the base .NET 9 runtime (Microsoft.NETCore.App).
class Program
{
    /// <summary>
    /// A simple .NET 9 CLI application to verify runtime activation.
    /// </summary>
    /// <returns>Returns 0 on success, non-zero on failure.</returns>
    static int Main(string[] args)
    {
        Console.WriteLine("==============================================");
        Console.WriteLine(" .NET 9 CLI Tester -- Execution Successful!");
        Console.WriteLine("==============================================");
        Console.WriteLine($" -> OS Version: {Environment.OSVersion}");
        Console.WriteLine($" -> OS Architecture: {RuntimeInformation.OSArchitecture}");
        Console.WriteLine($" -> Process Architecture: {RuntimeInformation.ProcessArchitecture}");
        Console.WriteLine($" -> .NET Runtime Version: {Environment.Version}");
        Console.WriteLine($" -> Framework Description: {RuntimeInformation.FrameworkDescription}");
        Console.WriteLine("SUCCESS: .NET 9 CLI Runtime is installed and working correctly.");

        // If the program reaches this point, the .NET runtime was found and activated successfully.
        // A return code of 0 indicates success, which is a standard convention.
        return 0;
    }
}