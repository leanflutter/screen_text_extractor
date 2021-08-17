var _parentWindow = window.parent;
var _parentDocument = window.parent.document;

function screenTextExtractorExtractFromScreenCapture(cb) {
  const body = _parentDocument.body;
  _parentWindow.domtoimage.toPng(body).then(function (dataUrl) {
    const imageWidth = body.scrollWidth;
    const imageHeight = body.scrollHeight;
    var image = new Image();
    image.src = dataUrl;
    image.style.width = imageWidth + "px";
    image.style.height = imageHeight + "px";
    _parentDocument.body.appendChild(image);
    const cropper = new _parentWindow.Cropper(image, {
      minContainerWidth: imageWidth,
      minContainerHeight: imageHeight,
      autoCrop: false,
      zoomable: false,
      zoomOnTouch: false,
      zoomOnWheel: false,
      cropend: function () {
        var data = cropper.getData();
        var croppedCanvas = cropper.getCroppedCanvas();
        var base64Image = croppedCanvas.toDataURL("image/png");

        image.remove();
        cropper.destroy();

        cb({
          imageWidth: data.width,
          imageHeight: data.height,
          base64Image: base64Image.replace("data:image/png;base64,", ""),
        });
      },
    });
  });
}

function screenTextExtractorExtractFromScreenSelection() {
  const selection = _parentDocument.getSelection();

  if (selection.rangeCount === 0) return;

  const selectionRange = selection.getRangeAt(0);
  const selectionRect = selectionRange.getBoundingClientRect();
  // 未获取 x/y 轴的值，不进行任何操作
  if (selectionRect.x === 0 && selectionRect.y === 0) return;

  const text = selection.toString().trim() || "";

  return { text };
}
