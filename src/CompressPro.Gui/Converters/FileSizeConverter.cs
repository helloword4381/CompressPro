using System.Globalization;
using System.Windows.Data;

namespace CompressPro.Gui.Converters;

/// <summary>
/// 字节 → 可读大小字符串
/// </summary>
[ValueConversion(typeof(long), typeof(string))]
public class FileSizeConverter : IValueConverter
{
    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
        if (value is long bytes)
            return FormatSize(bytes);
        if (value is double d)
            return FormatSize((long)d);
        return "0 B";
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        => throw new NotSupportedException();

    private static string FormatSize(long bytes) => bytes switch
    {
        < 0 => "0 B",
        < 1024 => $"{bytes} B",
        < 1024 * 1024 => $"{bytes / 1024.0:F1} KB",
        < 1024L * 1024 * 1024 => $"{bytes / (1024.0 * 1024):F1} MB",
        _ => $"{bytes / (1024.0 * 1024 * 1024):F2} GB"
    };
}
