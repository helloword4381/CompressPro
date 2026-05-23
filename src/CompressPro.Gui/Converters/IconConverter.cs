using System.Globalization;
using System.Windows.Data;

namespace CompressPro.Gui.Converters;

/// <summary>
/// IconKey → 显示图标 (使用 Unicode / Segoe MDL2 Assets)
/// </summary>
[ValueConversion(typeof(string), typeof(string))]
public class IconConverter : IValueConverter
{
    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
    {
        if (value is string key)
        {
            return key switch
            {
                "Folder" => "\U0001F4C1",       // 📁
                "Archive" => "\U0001F4E6",      // 📦
                "Executable" => "\u2699\uFE0F", // ⚙️
                "Text" => "\U0001F4DD",         // 📝
                "Image" => "\U0001F5BC",        // 🖼
                _ => "\U0001F4C4"               // 📄
            };
        }
        return "\U0001F4C4"; // 📄
    }

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        => throw new NotSupportedException();
}
