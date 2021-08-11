var _window = window.parent;
var _document = window.parent.document;

function screenTextExtractorExtractFromScreenSelection() {
  const selection = _document.getSelection();

  if (selection.rangeCount === 0) return;

  const selectionRange = selection.getRangeAt(0);
  const selectionRect = selectionRange.getBoundingClientRect();
  // 未获取 x/y 轴的值，不进行任何操作
  if (selectionRect.x === 0 && selectionRect.y === 0) return;

  const text = selection.toString().trim() || "";

  return { text };
}
