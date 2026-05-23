using System.Diagnostics;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using CompressPro.Core.Models;

namespace CompressPro.Gui.Services;

/// <summary>
/// 7z.exe 进程调用实现 — 无需 7z.dll 绑定，开箱即用
/// 作为 SevenZipSharp 集成前的过渡方案
/// </summary>
public partial class SevenZipExeService : ISevenZipService
{
    private string _sevenZipPath;

    public SevenZipExeService(string? sevenZipPath = null)
    {
        _sevenZipPath = sevenZipPath ?? LocateSevenZip();
    }

    private static string LocateSevenZip()
    {
        // 1. 优先使用自带的 7z.exe（集成版）
        var baseDir = AppDomain.CurrentDomain.BaseDirectory;

        var bundled7z = Path.Combine(baseDir, "7z.exe");
        if (File.Exists(bundled7z))
            return bundled7z;

        // 1b. 也可能是 7za.exe (v26+ 重命名)
        var bundled7za = Path.Combine(baseDir, "7za.exe");
        if (File.Exists(bundled7za))
            return bundled7za;

        // 2. 找 7z.dll（自带的集成版）
        var bundledDll = Path.Combine(baseDir, "7z.dll");
        if (File.Exists(bundledDll))
            return bundled7z;

        // 3. 系统安装的 7-Zip
        var candidates = new[]
        {
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "7-Zip", "7z.exe"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86), "7-Zip", "7z.exe"),
        };

        return candidates.FirstOrDefault(File.Exists)
               ?? throw new FileNotFoundException(
                   "未找到 7z.dll/7z.exe。\n" +
                   "请运行 external\\download_7z_dll.bat 下载，或安装 7-Zip");
    }

    public async Task<List<ArchiveFileInfo>> ListArchiveAsync(string archivePath)
    {
        var (stdout, _) = await Run7zAsync($"l \"{archivePath}\"");

        var entries = new List<ArchiveFileInfo>();
        var inFiles = false;

        // 解析 7z l 命令输出格式
        foreach (var line in stdout.Split('\n'))
        {
            var trimmed = line.TrimEnd('\r');

            if (trimmed.Contains("----"))
            {
                inFiles = !inFiles;
                continue;
            }

            if (!inFiles) continue;

            // 典型行: 2024-01-15 10:30:00 .....A. 1234 567  filename
            try
            {
                var match = ListLineRegex().Match(trimmed);
                if (!match.Success || match.Groups.Count < 6) continue;

                var dateStr = match.Groups[1].Value.Trim();
                var sizeStr = match.Groups[3].Value.Trim();
                var name = match.Groups[5].Value.Trim();

                var isFolder = match.Groups[2].Value.Contains('D');
                var size = long.TryParse(sizeStr, out var s) ? s : 0;

                DateTime.TryParse(dateStr, out var date);

                entries.Add(new ArchiveFileInfo
                {
                    FileName = Path.GetFileName(name),
                    FullPath = name,
                    UncompressedSize = size,
                    ModifiedDate = date,
                    IsFolder = isFolder,
                });
            }
            catch
            {
                // 跳过无法解析的行
            }
        }

        return entries;
    }

    public async Task ExtractAsync(string archivePath, string outputDir, string? password = null)
    {
        var passArg = string.IsNullOrEmpty(password) ? "" : $"-p\"{password}\"";
        var (_, exitCode) = await Run7zAsync($"x \"{archivePath}\" -o\"{outputDir}\" -y {passArg}");

        if (exitCode != 0)
            throw new Exception($"7z.exe 返回错误码: {exitCode}");
    }

    public async Task<bool> TestArchiveAsync(string archivePath)
    {
        var (_, exitCode) = await Run7zAsync($"t \"{archivePath}\"");
        return exitCode == 0;
    }

    public async Task CompressAsync(IEnumerable<string> files, string archivePath,
        CompressionOptions? options = null, IProgress<double>? progress = null)
    {
        var opt = options ?? CompressionOptions.Default;
        var fileList = string.Join(" ", files.Select(f => $"\"{f}\""));
        var level = opt.CompressionLevel;
        var passArg = string.IsNullOrEmpty(opt.Password) ? "" : $"-p\"{opt.Password}\"";
        var formatArg = opt.Format switch
        {
            "zip" => "-tzip",
            "7z" => "-t7z",
            "tar" => "-ttar",
            _ => "-tzip"
        };

        var (_, exitCode) = await Run7zAsync(
            $"a {formatArg} -mx={level} {passArg} \"{archivePath}\" {fileList}");

        if (exitCode != 0)
            throw new Exception($"7z.exe 返回错误码: {exitCode}");
    }

    private async Task<(string stdout, int exitCode)> Run7zAsync(string arguments)
    {
        var tcs = new TaskCompletionSource<(string, int)>();

        var psi = new ProcessStartInfo
        {
            FileName = _sevenZipPath,
            Arguments = arguments,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
            CreateNoWindow = true,
            StandardOutputEncoding = Encoding.UTF8,
            StandardErrorEncoding = Encoding.UTF8
        };

        var proc = new Process { StartInfo = psi };
        var output = new StringBuilder();
        var error = new StringBuilder();

        proc.OutputDataReceived += (_, e) => output.AppendLine(e.Data);
        proc.ErrorDataReceived += (_, e) => error.AppendLine(e.Data);
        proc.Exited += (_, _) => tcs.TrySetResult((output.ToString(), proc.ExitCode));

        proc.Start();
        proc.BeginOutputReadLine();
        proc.BeginErrorReadLine();

        var result = await tcs.Task;
        return result;
    }

    [GeneratedRegex(@"^(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})\s+([.D]....[AR])\s+(\d+)\s+(\d+)\s+(.+)$")]
    private static partial Regex ListLineRegex();
}
