using System.Diagnostics;
using System.Text;
using CompressPro.Core.Models;

namespace CompressPro.Gui.Services;

/// <summary>
/// SevenZipSharp 实现 — 直接调用 7z.dll (推荐)
/// </summary>
public class SevenZipService : ISevenZipService
{
    public Task<List<ArchiveFileInfo>> ListArchiveAsync(string archivePath)
    {
        // TODO: 集成 SevenZipSharp NuGet 包后实现
        // using var extractor = new SevenZipExtractor(archivePath);
        //
        // return extractor.ArchiveFileData.Select(f => new ArchiveFileInfo
        // {
        //     FileName = f.FileName,
        //     UncompressedSize = (long)f.Size,
        //     CompressedSize = (long)f.PackedSize,
        //     ModifiedDate = f.LastWriteTime,
        //     Crc = f.Crc?.ToString("X8"),
        //     IsFolder = f.IsDirectory,
        //     FullPath = f.FileName
        // }).ToList();

        throw new NotImplementedException("需安装 SevenZipSharp.Interop NuGet 包并放置 7z.dll");
    }

    public Task ExtractAsync(string archivePath, string outputDir, string? password = null)
    {
        // using var extractor = new SevenZipExtractor(archivePath, password);
        // extractor.ExtractArchive(outputDir);
        // return Task.CompletedTask;

        throw new NotImplementedException("需安装 SevenZipSharp.Interop NuGet 包");
    }

    public Task<bool> TestArchiveAsync(string archivePath)
    {
        // using var extractor = new SevenZipExtractor(archivePath);
        // extractor.CheckHeaders();
        // return Task.FromResult(true);

        throw new NotImplementedException("需安装 SevenZipSharp.Interop NuGet 包");
    }

    public Task CompressAsync(IEnumerable<string> files, string archivePath,
        CompressionOptions? options = null, IProgress<double>? progress = null)
    {
        // using var compressor = new SevenZipCompressor
        // {
        //     ArchiveFormat = OutArchiveFormat.SevenZip,
        //     CompressionLevel = (CompressionLevel)(options?.CompressionLevel ?? 5),
        //     EncryptHeaders = !string.IsNullOrEmpty(options?.Password)
        // };
        // compressor.CompressFiles(archivePath, files.ToArray());
        // return Task.CompletedTask;

        throw new NotImplementedException("需安装 SevenZipSharp.Interop NuGet 包");
    }
}
