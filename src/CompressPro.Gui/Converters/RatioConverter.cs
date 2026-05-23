using System.Globalization;
using System.Windows.Data;

namespace CompressPro.Gui.Converters;

/// <summary>
/// 压缩比数字 → 显示字符串
/// </summary>
[ValueConversion(typeof(double), typeof(string))]
public class RatioConverter : IValueConverter
{
    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
        if (value is double ratio)
        {
            if (ratio <= 0) return "-";
            return $"{ratio:F1}%";
        }
        return "-";
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        => throw new NotSupportedException();
}
