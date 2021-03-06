package fonthx.examples.pixelfonter;

import fonthx.utils.ExecutionTimer;
import fonthx.formats.tt.FontFileFormat;
import fonthx.formats.tt.TrueTypeBuilder;
import haxe.io.Bytes;

using StringTools;
using Lambda;

/**
* The core pixelfonter module
**/
class PixelFonter {

    public static function build(opts:PixelFonterParams):Bytes {

        ExecutionTimer.start('PixelFonter::generate');

        // parse codepoint string
        var codepointSegments = opts.codepointString.split(',');

        // assemble full list of codepoints
        var codepoints:Array<Int> = codepointSegments.fold(function(segment:String, cps:Array<Int>) {
            var extremes = segment.split('-');
            for (i in Std.parseInt(extremes[0])...Std.parseInt(extremes[1]) + 1) {
                cps.push(i);
            }
            return cps;
        }, new Array<Int>());

        var em = 1024;
        var pixelSize = Std.int(em / opts.glyphWidth);

        // create the font with an emSquare
        var font = new PixelFont(opts.name, em, pixelSize);

        // build the glyph data
        var numRows = opts.imageHeight / opts.glyphHeight;
        for (idx in 0 ... codepoints.length) {
            var glyph = font.addGlyph(codepoints[idx]);
            //trace('Creating glyph at codepoint ${glyph.codepoint}');
            for (dy in 0 ... opts.glyphHeight) {
                for (dx in 0 ... opts.glyphWidth) {
                    var x = (idx * opts.glyphWidth + dx);
                    var row = Std.int(Math.floor(x / opts.imageWidth));
                    x = x % opts.imageWidth;
                    var y = dy + (row * opts.glyphHeight);
                    var idx = ((y * opts.imageWidth) + x) * 4;
                    var colour = opts.pixelData.get(idx);
                    if (colour != 0) continue;
                    glyph.addPixel(dx, opts.glyphHeight - dy); // note inverted y axis
                }
            }
        }

        font.prepareForExport();
        var bytes = TrueTypeBuilder.build(font, TrueType);

        ExecutionTimer.end('PixelFonter::generate');

        return bytes;
    }


}
