import 'dart:html';
import 'dart:math';

Point cp1 = new Point(107, 109);
Point cp2 = new Point(97, 127);

void main() {
  CanvasElement canvas = querySelector('#canvas');
  CanvasRenderingContext2D ctx = canvas.getContext('2d');

  render(ctx);

  canvas.onClick.listen((MouseEvent ev) {
    ev.preventDefault();
    if(ev.ctrlKey) {
      cp1 = ev.offset;
      print('cp1=$cp1');
    } else {
      cp2 = ev.offset;
      print('cp2=$cp2');
    }
    render(ctx);
  });
}

void render(CanvasRenderingContext2D ctx) {
  ctx.clearRect(0, 0, 300, 300);
  ctx.lineWidth = 2;
  ctx.strokeStyle = '#008000';
  ctx.fillStyle = '#008000';

  ctx.moveTo(302.89749,282.93398);
  ctx.beginPath();
  ctx.bezierCurveTo(323.27705,257.23445,328.90642,254.09025,336.64152,225.70002);
  ctx.bezierCurveTo(338.9146,217.35711,336.86793,186.55545,327.22849,151.03134);
  ctx.stroke();

  ctx.moveTo(398.91901, 290.95918);
  ctx.beginPath();
  ctx.bezierCurveTo(391.0143,254.14797,389.95624,255.41283,380.78811,227.45246);
  ctx.bezierCurveTo(370.43428,195.87604,357.15601,188.30789,327.8186,150.76347);
  ctx.stroke();

  // Right Leaf
  ctx.moveTo(327.6309,150.92789);
  ctx.beginPath();
  ctx.bezierCurveTo(360.63737,149.47202,383.81417,142.52322,403.6534,124.5062);
  ctx.bezierCurveTo(426.33851,103.90469,432.10544,69.614974,459.33657,66.920817);
  ctx.stroke();

  ctx.moveTo(327.5263,150.75728);
  ctx.beginPath();
  ctx.bezierCurveTo(333.76373,125.56283,337.54104,102.41832,357.38027,84.401303);
  ctx.bezierCurveTo(380.06538,63.7998,404.07371,67.480092,461.10434,66.80624);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = '#ff0000';

  /*

  ctx.strokeStyle = '#008000';
  ctx.beginPath();
  ctx.moveTo(99, 64);
  ctx.bezierCurveTo(cp1.x, cp1.y, cp2.x, cp2.y, 80, 160);
  ctx.stroke();

  ctx.beginPath();
  ctx.arc(72, 185, 28, 0, 2* PI);
  ctx.fillStyle = '#ff0000';
  ctx.fill();

  ctx.arc(151, 197, 34, 0, 2* PI);
  ctx.fill();
  */
}