import "package:markdown/markdown.dart";

ExtensionSet extButtMD(Set<EmojiSet> db) => ExtensionSet(<BlockSyntax>[
      const FencedCodeBlockSyntax(),
      const BlockquoteSyntax(),
      const CodeBlockSyntax(),
      const DummyBlockSyntax(),
      const TableSyntax(),
      const HeaderWithIdSyntax(),
      const UnorderedListWithCheckboxSyntax(),
      const OrderedListWithCheckboxSyntax(),
      const FootnoteDefSyntax(),
      const AlertBlockSyntax(),
      const BlockLangSyntax(),
      const HeaderSyntax(),
      const HorizontalRuleSyntax(),
      const HtmlBlockSyntax(),
      const OrderedListSyntax(),
      const UnorderedListSyntax(),
      const ParagraphSyntax(),
    ], <InlineSyntax>[
      InlineHtmlSyntax(),
      StrikethroughSyntax(),
      AutolinkExtensionSyntax(),
      ColorSwatchSyntax(),
      EmojiSyntax(),
      EmojiExtensionSyntax(db),
      InlineLangSyntax(),
      EscapeHtmlSyntax(),
      EscapeSyntax(),
      LineBreakSyntax(),
      SoftLineBreakSyntax(),
    ]);

class BlockLangSyntax extends BlockSyntax {
  const BlockLangSyntax();
  @override
  Node? parse(BlockParser parser) {
    // TODO: implement parse
    throw UnimplementedError();
  }

  @override
  // TODO: implement pattern
  RegExp get pattern => throw UnimplementedError();
}

class InlineLangSyntax extends InlineSyntax {
  InlineLangSyntax() : super("");

  @override
  bool onMatch(InlineParser parser, Match match) {
    // TODO: implement onMatch
    throw UnimplementedError();
  }
}

class EmojiExtensionSyntax extends InlineSyntax {
  final Set<EmojiSet> db;
  EmojiExtensionSyntax(this.db) : super(r":(((([A-Z][a-z0-9]*)([A-Z][a-z0-9]*)*)(_([A-Z][a-z]*)([A-Z][a-z]*)*)*)(\.(([A-Z][a-z0-9]*)([A-Z][a-z0-9]*)*)(_([A-Z][a-z0-9]*)([A-Z][a-z0-9]*)*)*)*):");
  @override
  bool onMatch(InlineParser parser, Match match) {
    final Iterable<String> alias = match[1]!.split(".");
    Iterable<EmojiSet> base = this.db;
    Iterable<EmojiSet> cand = <EmojiSet>[];
    late EmojiSet candE;
    for (int i = 0; i < alias.length; i++) {
      cand = base.where((EmojiSet s) => s.name == alias.elementAt(i));
      if (cand.isNotEmpty) {
        candE = cand.first;
        if (candE is EmojiEntry) {
          if (i + 1 == alias.length) {
            parser.addNode(AttrElement("img", attributes: {"src": candE.emoji}));
            return true;
          } else {
            parser.advanceBy(1);
            return false;
          }
        } else if (candE.children.isNotEmpty) {
          base = candE.children;
        } else {
          parser.advanceBy(1);
          return false;
        }
      }
    }
    parser.advanceBy(1);
    return false;
  }
}

class AttrElement extends Element {
  @override
  final Map<String, String> attributes;
  AttrElement(String tag, {List<Node>? children, Map<String, String>? attributes})
      : this.attributes = attributes ?? {},
        super(tag, children);
}

class EmojiSet {
  final String name;
  final Set<EmojiSet> children;
  EmojiSet(this.name, {Set<EmojiSet>? children}) : this.children = children ?? <EmojiSet>{};
}

class EmojiEntry extends EmojiSet {
  final String emoji;
  EmojiEntry(super.name, this.emoji, {Set<EmojiSet>? children}) : super(children: children ?? <EmojiSet>{});
}
