program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp, neuralnetwork, neuralvolume, Math, neuraldatasets,
  neuralfit;;

begin

procedure ClassifyOneImageSimple;
  var
    NN: TNNet;
    ImageFileName: string;
    NeuralFit: TNeuralImageFit;
  begin
    WriteLn('Loading Neural Network...');
    NN := TNNet.Create;
    NN.LoadFromFile('SimplePlantLeafDisease-20230720.nn');
    NeuralFit := TNeuralImageFit.Create;
    ImageFileName := 'plant/Apple___Black_rot/image (1).JPG';
    WriteLn('Processing image: ', ImageFileName);
    WriteLn(
      'The class of the image is: ',
      NeuralFit.ClassifyImageFromFile(NN, ImageFileName)
    );
    NeuralFit.Free;
    NN.Free;
  end;
end.

