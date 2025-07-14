using System;
using System.Runtime.InteropServices;

namespace Dotnet9DesktopTester;

// This program specifically tests for the .NET 9 Desktop Runtime (Microsoft.WindowsDesktop.App).
// Its project file uses the WindowsDesktop SDK, which creates the dependency.
class Program
{
    static int Main(string[] args)
    {
        Console.WriteLine("==============================================");
        Console.WriteLine(" .NET 9 Desktop Runtime Tester -- Execution Successful!");
        Console.WriteLine("==============================================");
        Console.WriteLine($" -> OS Version: {Environment.OSVersion}");
        Console.WriteLine($" -> OS Architecture: {RuntimeInformation.OSArchitecture}");
        Console.WriteLine($" -> Process Architecture: {RuntimeInformation.ProcessArchitecture}");
        Console.WriteLine($" -> .NET Runtime Version: {Environment.Version}");
        Console.WriteLine($" -> Framework Description: {RuntimeInformation.FrameworkDescription}");
        Console.WriteLine("SUCCESS: .NET 9 Desktop Runtime is installed and working correctly.");

        return 0; // Return 0 for success
    }
}