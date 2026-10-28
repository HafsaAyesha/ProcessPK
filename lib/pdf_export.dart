import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'models.dart';
import 'strings.dart';

const _green = PdfColor.fromInt(0xFF0F6B50);
const _mint = PdfColor.fromInt(0xFFDFF4EC);
const _muted = PdfColor.fromInt(0xFF5B6B66);

/// Builds a printable PDF of a guide in [lang]. With [progress], documents
/// and steps the user has ticked are shown as done, and their notes are
/// included.
Future<Uint8List> buildGuidePdf(
  Guide guide,
  String lang, {
  GuideProgress? progress,
}) async {
  Future<pw.Font> font(String name) async =>
      pw.Font.ttf(await rootBundle.load('assets/fonts/$name.ttf'));
  final latin = await font('Inter-Regular');
  final latinBold = await font('Inter-Bold');
  final urdu = await font('NotoNaskhArabic-Regular');
  final urduBold = await font('NotoNaskhArabic-Bold');
  final isUrdu = lang == 'ur';
  final s = S(lang);
  final t = guide.text(lang);

  final theme = isUrdu
      ? pw.ThemeData.withFont(
          base: urdu,
          bold: urduBold,
          fontFallback: [latin, latinBold],
        )
      : pw.ThemeData.withFont(
          base: latin,
          bold: latinBold,
          fontFallback: [urdu, urduBold],
        );

  pw.Widget heading(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 13,
        fontWeight: pw.FontWeight.bold,
        color: _green,
      ),
    ),
  );

  pw.Widget body(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 10.5)),
  );

  pw.Widget checkRow(String text, bool done) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 5),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 10,
          height: 10,
          margin: const pw.EdgeInsets.only(top: 2),
          decoration: pw.BoxDecoration(
            color: done ? _green : null,
            border: pw.Border.all(color: _green, width: 1),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Text(text, style: const pw.TextStyle(fontSize: 10.5)),
        ),
      ],
    ),
  );

  final doc = pw.Document(title: t.title, author: 'ProcessPK');
  doc.addPage(
    pw.MultiPage(
      theme: theme,
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      textDirection: isUrdu ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      footer: (ctx) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 10),
        child: pw.Text(
          '${s.pdfFooter}   ${ctx.pageNumber}/${ctx.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: _muted),
        ),
      ),
      build: (_) => [
        pw.Text(
          'ProcessPK${progress != null ? ' · ${s.pdfChecklist}' : ''}',
          style: const pw.TextStyle(fontSize: 10, color: _green),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          t.title,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(t.summary, style: const pw.TextStyle(color: _muted)),
        pw.Text(
          s.lastVerified(guide.lastVerified),
          style: const pw.TextStyle(fontSize: 9, color: _muted),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: const pw.BoxDecoration(
            color: _mint,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                s.fees,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              body(t.fees),
              pw.Text(
                s.processingTime,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              body(t.time),
            ],
          ),
        ),
        heading(s.requiredDocuments),
        for (var i = 0; i < t.documents.length; i++)
          checkRow(t.documents[i], progress?.documents.contains(i) ?? false),
        heading(s.steps),
        for (var i = 0; i < t.steps.length; i++)
          checkRow(
            '${i + 1}. ${t.steps[i]}',
            progress?.steps.contains(i) ?? false,
          ),
        if (t.dates.isNotEmpty) ...[
          heading(s.importantDates),
          for (final d in t.dates) body('- $d'),
        ],
        if (t.mistakes.isNotEmpty) ...[
          heading(s.commonMistakes),
          for (final m in t.mistakes) body('- $m'),
        ],
        if (progress != null && progress.notes.trim().isNotEmpty) ...[
          heading(s.myNotes),
          body(progress.notes.trim()),
        ],
        if (guide.contacts.isNotEmpty) ...[
          heading(s.contacts),
          for (final c in guide.contacts)
            body(
              [
                c.label(lang),
                c.phone,
                c.email,
                c.url,
              ].whereType<String>().join('  ·  '),
            ),
        ],
        heading(s.officialSources),
        for (final src in guide.sources) body('${src.name}: ${src.url}'),
      ],
    ),
  );
  return doc.save();
}

Future<void> shareGuidePdf(
  Guide guide,
  String lang, {
  GuideProgress? progress,
}) async {
  final bytes = await buildGuidePdf(guide, lang, progress: progress);
  final name = 'ProcessPK-${guide.id}.pdf';
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(bytes, mimeType: 'application/pdf', name: name)],
      fileNameOverrides: [name],
      subject: guide.text(lang).title,
    ),
  );
}
