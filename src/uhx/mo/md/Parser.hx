package uhx.mo.md;

import haxe.io.Eof;
import uhx.mo.Token;
import hxparse.Lexer;
import byte.ByteData;
import haxe.CallStack;
import hxparse.Unexpected;
import hxparse.UnexpectedChar;
import uhx.mo.md.Lexer.Generic;
import uhx.mo.md.Lexer.Block;
import uhx.mo.md.Lexer.Leaf;
import uhx.mo.md.Lexer.Inline;
import uhx.mo.md.Lexer.Container;

using Mo;
using StringTools;
using haxe.io.Path;

/**
 * ...
 * @author Skial Bainn
 */
class Parser {

	private var lexer:Lexer;
	private var result:StringBuf;
	
	public function new() {
		
	}
	
	/*public function filterResources(tokens:Array<Token<MarkdownKeywords>>, map:Map<String, {url:String, title:String}>) {
		for (token in tokens) switch (token) {
			case Keyword(Resource(text, url, title)):
				map.set(text.toLowerCase().trim(), { url:url, title:title } );
				
			case Keyword(Paragraph(toks)), Keyword(Blockquote(toks)), Keyword(Item(_, toks)), Keyword(Collection(_, toks)):
				filterResources( toks, map );
				
			case _:
				
		}
	}*/
	
	public function toTokens(input:ByteData, name:String):Array<Generic> {
		var results = [];
		
		lexer = new Lexer( input, name );
		
		try {
			while (true) lexer.token( Lexer.root );
			
		} catch (e:Eof) {
			
			
		}
		
		return cast lexer.document.tokens;
	}
	
	/*public function printString(token:Token<MarkdownKeywords>):String {
		var result = '';
		
		switch (token) {
			case Dot: 
				result += '.';
				
			case Tilde: 
				result += '~';
				
			case Hyphen(len): 
				result += [for (i in 0...len) '-'].join('');
				
			case Carriage:
				result += '\r';
				
			case Newline:
				result += '\n';
				
			case Space(len): 
				result += [for (i in 0...len) ' '].join('');
				
			case Const(CString(s)): 
				result += s;
				
			case Keyword(Paragraph(tokens)) if (tokens.length > 0):
				result = [for (token in tokens) printString( token )].join('');
				
			case Keyword(Header(_, len, title)):
				result += title.map( function(t) printString( t ) ).join('');
				
			case Keyword(Italic(_, tokens)):
				result += [for (token in tokens) printString( token )].join('');
				
			case Keyword(Bold(_, tokens)):
				result += [for (token in tokens) printString( token )].join('');
				
			case Keyword(Strike(tokens)):
				result += [for (token in tokens) printString( token )].join('');
				
			case Keyword(Collection(ordered, tokens)):
				var l = ordered?'ol':'ul';
				result += '<$l>' + [for (token in tokens) printString( token )].join('') + '</$l>';
				
			case Keyword(Item(_, tokens)):
				result += [for (token in tokens) printString( token )].join('');
				
			case Keyword(Link(_, text, url, title)):
				result += text;
				
			case Keyword(Image(_, text, url, title)):
				result += text;
				
			case Keyword(Code(fenced, lang, code)):
				result += code;
				
			case Keyword(Blockquote(tokens)):
				result += [for (token in tokens) printString( token )].join('');
				
			/*case Keyword(Horizontal(_)):
				result += '<hr />';*/
				
			/*case _:
		}
		
		return result;
	}
	
	public function printHTML(token:Token<MarkdownKeywords>, res:Map<String, { url:String, title:String }>):String {
		var result = '';
		
		switch (token) {
			case Dot: 
				result += '.';
				
			case Tilde: 
				result += '~';
				
			case Hyphen(len): 
				result += [for (i in 0...len) '-'].join('');
				
			case Newline, Carriage:
				result += ' ';
				
			case Space(len): 
				result += [for (i in 0...len) ' '].join('');
				
			case Const(CString(s)): 
				result += s;
				
			case Keyword(Paragraph(tokens)) if (tokens.length > 0):
				var content = [for (token in tokens) printHTML( token, res )].join('');
				if (content != '') result += '<p>$content</p>';
				
			case Keyword(Header(_, len, title)):
				result += '<h$len>' + title.map( function(t) return printHTML( t, res ) ).join('') + '</h$len>';
				
			case Keyword(Italic(_, tokens)):
				result += '<em>' + [for (token in tokens) printHTML( token, res )].join('') + '</em>';
				
			case Keyword(Bold(_, tokens)):
				result += '<strong>' + [for (token in tokens) printHTML( token, res )].join('') + '</strong>';
				
			case Keyword(Strike(tokens)):
				result += '<del>' + [for (token in tokens) printHTML( token, res )].join('') + '</del>';
				
			case Keyword(Collection(ordered, tokens)):
				var l = ordered?'ol':'ul';
				result += '<$l>' + [for (token in tokens) printHTML( token, res )].join('') + '</$l>';
				
			case Keyword(Item(_, tokens)):
				result += '<li>' + [for (token in tokens) printHTML( token, res )].join('') + '</li>';
				
			case Keyword(Link(false, text, url, title)):
				result += '<a href="$url"';
				result += title == '' ? ' ' : ' title="$title"';
				result += '>$text</a>';
				
			case Keyword(Link(true, text, url, title)):
				var key = url.toLowerCase().trim();
				
				if (res.exists( key )) {
					var res = res.get( key );
					
					url = res.url;
					title = res.title;
					
					result += '<a href="$url"';
					result += title == '' ? ' ' : ' title="$title"';
					result += '>$text</a>';
				} else {
					result += '[$text]';
				}
				
			case Keyword(Image(false, text, url, title)):
				switch (text) {
					case _.indexOf( 'youtube' ) > -1 => true:
						result += embed(text, url, youtube);
						
					case _.indexOf( 'vimeo' ) > -1 => true:
						result += embed(text, url, vimeo);
						
					case _.indexOf( 'slideshare' ) > -1 => true:
						result += embed(text, url, slideshare);
						
					case _.indexOf( 'speakerdeck' ) > -1 => true:
						result += embed(text, url, speakerdeck);
						
					case _.indexOf( 'iframe' ) > -1 => true:
						result += embed(text, url, iframe);
						
					case _ if (url.endsWith( 'mp4' )):
						result += embed(text, url, function(_, w, h) {
							if (w != '') w = ' width="$w"';
							if (h != '') h = ' height="$h"';
							return '<video$w$h controls="" loop=""' + (title == '' ? ' ' : ' title="$title"') + '>'
							+ '\r\n\t<source src="$url" type="video/mp4" />'
							+ '\r\n</video>';
						}, false );
						
					case _:
						result += '<img src="$url" alt="$text"';
						result += title == '' ? ' ' : ' title="$title"';
						result += ' />';
						
				}
				
			case Keyword(Image(true, text, url, title)):
				var key = url.toLowerCase().trim();
				
				if (res.exists( key )) {
					var res = res.get( key );
					
					url = res.url;
					title = res.title;
					
					result += '<img src="$url" alt="$text"';
					result += title == '' ? ' ' : ' title="$title"';
					result += ' />';
				} else {
					result += '[$text]';
				}
				
			case Keyword(Code(fenced, lang, code)):
				result += (fenced ? '<pre' + (lang != '' ? ' language="${lang.toLowerCase()}"' : '') + '>' : '') + '<code';
				result += (lang != '' ? ' language="${lang.toLowerCase()}"' : '') + '>';
				result += code.replace('<', '&lt;').replace('>', '&gt;');
				result += '</code>' + (fenced ? '</pre>' : '');
				
			case Keyword(Blockquote(tokens)):
				result += '<blockquote>' + [for (token in tokens) printHTML( token, res )].join('') + '</blockquote>';
				
			case Keyword(Horizontal(_)):
				result += '<hr />';
				
			case _:
		}
		
		return result;
	}
	
	private function embed(text:String, url:String, method:String->String->String->String, remove:Bool = true):String {
		var w = '';
		var h = '';
		var parts = find(text, ~/[\d]+[%]?x[\d]+[%]?/, remove);
		
		if (parts.length > 1) switch (parts[1].split('x')) {
			case [a, b]:
				w = a;
				h = b;
				text = parts[0];
				
			case _:
				
		}
		
		return method(url, w, h);
	}
	
	private function find(text:String, ereg:EReg, remove:Bool = false):Array<String> {
		var originals = text.split(' ');
		var results = [];
		var removables = [];
		
		if (originals.length > 0) for (original in originals) {
			if (ereg.match( original )) {
				if (remove) removables.push( original );
				results.push( original );
			}
		}
		
		for (removable in removables) {
			originals.remove( removable );
		}
		
		results.unshift( originals.join(' ') );
		
		return results;
	}
	
	private function youtube(id:String, width:String, height:String):String {
		return element('iframe', [
			width == '' ? '' : ' width="$width"', 
			height == '' ? '' : ' height="$height"',
			' src="//' + 'www.youtube.com/embed/$id'.normalize() + '"',
			' frameborder="0"', ' webkitallowfullscreen=""',
			' mozallowfullscreen=""', ' allowfullscreen=""'
		] );
	}
	
	private function vimeo(id:String, width:String, height:String):String {
		return element('iframe', [
			width == '' ? '' : ' width="$width"', 
			height == '' ? '' : ' height="$height"',
			' src="//' + 'player.vimeo.com/video/$id'.normalize() + '"',
			' frameborder="0"', ' webkitallowfullscreen=""',
			' mozallowfullscreen=""', ' allowfullscreen=""'
		] );
	}
	
	private function speakerdeck(id:String, width:String, height:String):String {
		return element('iframe', [
			width == '' ? '' : ' width="$width"', 
			height == '' ? '' : ' height="$height"',
			' src="//' + 'http://speakerdeck.com/embed/$id'.normalize() + '"',
			' frameborder="0"', ' webkitallowfullscreen=""',
			' mozallowfullscreen=""', ' allowfullscreen=""'
		] );
	}
	
	private function slideshare(id:String, width:String, height:String):String {
		return element('iframe', [
			width == '' ? '' : ' width="$width"', 
			height == '' ? '' : ' height="$height"',
			' src="//' + 'www.slideshare.net/slideshow/embed_code/$id'.normalize() + '"',
			' frameborder="0"', ' webkitallowfullscreen=""',
			' mozallowfullscreen=""', ' allowfullscreen=""'
		] );
	}
	
	private function iframe(url:String, width:String, height:String):String {
		return element('iframe', [
			width == '' ? '' : ' width="$width"', 
			height == '' ? '' : ' height="$height"',
			' src="${url.normalize()}"',
			' frameborder="0"', ' webkitallowfullscreen=""',
			' mozallowfullscreen=""', ' allowfullscreen=""'
		] );
	}
	
	private function element(html:String, attributes:Array<String>):String {
		return '<$html' + attributes.join('') + '></$html>';
	}*/
	
}