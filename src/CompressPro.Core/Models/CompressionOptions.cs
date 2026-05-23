namespace CompressPro.Core.Models;

/// <summary>
/// 压缩选项配置
/// </summary>
public class CompressionOptions
{
    /// <summary>压缩格式 (zip/7z/tar/gz/bz2)</summary>
    public string Format { get; set; } = "zip";

    /// <summary>压缩等级 0-9 (0=仅存储, 9=最大压缩)</summary>
    public int CompressionLevel { get; set; } = 5;

    /// <summary>加密密码 (空=不加密)</summary>
    public string? Password { get; set; }

    /// <summary>加密方法 (AES-256 / ZipCrypto)</summary>
    public string EncryptionMethod { get; set; } = "AES-256";

    /// <summary>分卷大小 (字节, 0=不分卷)</summary>
    public long VolumeSize { get; set; } = 0;

    /// <summary>是否递归子目录</summary>
    public bool RecurseSubdirectories { get; set; } = true;

    /// <summary>要排除的文件模式 (逗号分隔)</summary>
    public string? ExcludeMasks { get; set; }

    /// <summary>压缩后删除源文件</summary>
    public bool DeleteSourceAfterCompression { get; set; } = false;

    /// <summary>创建自解压 SFX (仅 7z 格式)</summary>
    public bool CreateSfx { get; set; } = false;

    public static CompressionOptions Default => new();
}
