program project1;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Classes, SysUtils, CustApp, neuralnetwork, neuralvolume, Math, neuraldatasets,
  neuralfit;

type

  { TTestCNNAlgo }
  TTestCNNAlgo = class(TCustomApplication)
  protected
    procedure DoRun; override;
    procedure DoRunDetailed;
  end;

  procedure TTestCNNAlgo.DoRun;
  var
    RunSimple: boolean;
  begin
    RunSimple := true;
    if RunSimple
    then DoRunDetailed;
  end;

  procedure TTestCNNAlgo.DoRunDetailed;
  var
    NN: TNNet;
    ImageFileName: string;
    NeuralFit: TNeuralImageFit;
    vInputImage, vOutput: TNNetVolume;
    InputSizeX, InputSizeY, NumberOfClasses: integer;
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

    ImageFileName := 'to.PNG';
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
    ReadLn();

    NeuralFit.Free;
    NN.Free;
    Terminate;
  end;

var
  Application: TTestCNNAlgo;
begin
  Application := TTestCNNAlgo.Create(nil);
  Application.Title:='MNist Test';
  Application.Run;
  Application.Free;
end.

