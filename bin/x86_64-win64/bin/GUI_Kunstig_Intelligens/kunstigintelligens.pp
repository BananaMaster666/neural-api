unit KunstigIntelligens;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, FileUtil, Forms, Graphics, StdCtrls, Dialogs, ExtCtrls, CustApp,
  neuralnetwork, neuralvolume, Math, neuraldatasets, neuralfit, Classes;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Image1: TImage;
    Memo1: TMemo;
    WritelnTestButton: TButton;
    procedure Button1Click(Sender: TObject);
  end;

  procedure AssignWritelnMemo(var tf: TextFile);

  function WritelnMemoOpenFunction(var f: TTextRec): integer;

  function MemoOutput(var f: TTextRec): integer;

  function MemoClose(var {%H-}f: TTextRec): integer;

var
  Form1: TForm1;
  fileName: string;

implementation

procedure AssignWritelnMemo(var tf: TextFile);
begin
  with TTextRec(tf) do begin
    Handle:=$FFFF;
    Mode:=fmClosed;
    bufsize:=SizeOf(buffer);
    bufptr:=@buffer;
    openfunc:=@WritelnMemoOpenFunction;
    name[0]:=#0;
  end;
end;

function WritelnMemoOpenFunction(var f: TTextRec): integer;
begin
  with f do begin
    Mode:=fmOutput;
    inoutfunc:=@MemoOutput;
    flushfunc:=@MemoOutput;
    closefunc:=@MemoClose;
    Result:=0;
  end;
end;

function MemoOutput(var f: TTextRec): integer;
var
  succeeded: boolean;
begin
  if (f.bufpos <> 0) then begin
    f.buffer[f.bufpos]:=#0;
    repeat
      succeeded:=True;
      try
        Form1.memo1.Lines.Add('[WritelnMemo] ' + PChar(f.bufptr));
      except
        succeeded:=False;
      end;
    until succeeded;
    f.bufpos:=0;
  end;
  Result:=0;
end;

function MemoClose(var f: TTextRec): integer;
begin
  Exit(0);
end;

{$R *.lfm}

{ TForm1 }


procedure TForm1.Button1Click(Sender: TObject);
  var
    NN: TNNet;
    ImageFileName: string;
    NeuralFit: TNeuralImageFit;
    vInputImage, vOutput: TNNetVolume;
    InputSizeX, InputSizeY, NumberOfClasses: integer;
    i:timage;
  begin
    WriteLn('Loading Neural Network...');
    NN := TNNet.Create;
    NN.LoadFromFile('SimpleMNist.nn');
    NN.DebugStructure();
    InputSizeX := NN.Layers[0].Output.SizeX;
    InputSizeY := NN.Layers[0].Output.SizeY;
    NumberOfClasses := NN.GetLastLayer().Output.Size;

    NeuralFit := TNeuralImageFit.Create;
    vInputImage := TNNetVolume.Create();
    vOutput := TNNetVolume.Create(NumberOfClasses);

    ImageFileName := Edit1.text;
  i:=timage.Create(nil);
  i.Picture.LoadFromFile(ImageFileName);
  image1.Picture.Bitmap:=i.Picture.Bitmap;
  i.Free;
    WriteLn('Loading image: ',ImageFileName);

    if LoadImageFromFileIntoVolume(
      ImageFileName, vInputImage{ InputSizeX, InputSizeY,
      EncodeNeuronalInput=csEncodeRGB}) then
    begin
      WriteLn('Classifying the image:', ImageFileName);
      vOutput.Fill(0);
      NeuralFit.ClassifyImage(NN, vInputImage, vOutput);
      WriteLn('The image belongs to the class of images: ', vOutput.GetClass());
    end
    else
    begin
      WriteLn('Failed loading image: ',ImageFileName);
    end;

    vInputImage.Free;
    vOutput.Free;

    WriteLn('Press ENTER to quit.');

    NeuralFit.Free;
    NN.Free;
  end;






initialization
  AssignWritelnMemo(Output);
  Rewrite(Output);

end.
