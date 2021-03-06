unit DSSGlobals;

{$mode delphi}

interface

uses
  Classes, SysUtils,dssclassdefs,circuit,dssclass,dssobject,ParserDel, Hashlist, PointerList,
       UComplex, Arraydef, CktElement,
         {Some units which have global vars defined here}
     Spectrum,
     LoadShape,
     TempShape,
     PriceShape,
     GrowthShape,
     Monitor,
     EnergyMeter,
     Sensor,
     Feeder,
     WireData,
     CNData,
     TSData,
     LineSpacing;
CONST
     CRLF = #13#10;

      PI =  3.14159265359;

      TwoPi = 2.0 * PI;

      RadiansToDegrees = 57.29577951;

      EPSILON = 1.0e-12;   // Default tiny floating point
      EPSILON2 = 1.0e-3;   // Default for Real number mismatch testing

      POWERFLOW  = 1;  // Load model types for solution
      ADMITTANCE = 2;

      // For YPrim matrices
      ALL_YPRIM = 0;
      SERIES = 1;
      SHUNT  = 2;

      {Control Modes}
      CONTROLSOFF = -1;
      EVENTDRIVEN =  1;
      TIMEDRIVEN  =  2;
      CTRLSTATIC  =  0;

      {Randomization Constants}
      GAUSSIAN  = 1;
      UNIFORM   = 2;
      LOGNORMAL = 3;

      {Autoadd Constants}
      GENADD = 1;
      CAPADD = 2;

      {ERRORS}
      SOLUTION_ABORT = 99;

      {For General Sequential Time Simulations}
      USEDAILY  = 0;
      USEYEARLY = 1;
      USEDUTY   = 2;
      USENONE   =-1;

      {Earth Model}
      SIMPLECARSON  = 1;
      FULLCARSON    = 2;
      DERI          = 3;

      {Profile Plot Constants}
      PROFILE3PH = 9999; // some big number > likely no. of phases
      PROFILEALL = 9998;
      PROFILEALLPRI = 9997;
      PROFILELLALL = 9996;
      PROFILELLPRI = 9995;
      PROFILELL    = 9994;
var
     DLLFirstTime   :Boolean=TRUE;
   DLLDebugFile   :TextFile;
   ProgramName    :String;
   NoFormsAllowed  :Boolean;

    ActiveCircuit   :TDSSCircuit;
          ActiveDSSClass  :TDSSClass;
   LastClassReferenced:Integer;  // index of class of last thing edited
   ActiveDSSObject :TDSSObject;
   NumCircuits     :Integer;
   MaxCircuits     :Integer;
   MaxBusLimit     :Integer; // Set in Validation
   MaxAllocationIterations :Integer;
   Circuits        :TNPointerList;
   DSSObjs         :TNPointerList;

   AuxParser       :TParser;  // Auxiliary parser for use by anybody for reparsing values
   ErrorPending       :Boolean;
   CmdResult,
   ErrorNumber        :Integer;
   LastErrorMessage   :String;

   DefaultEarthModel  :Integer;
   ActiveEarthModel   :Integer;

   LastFileCompiled   :String;
   LastCommandWasCompile :Boolean;

   CALPHA             :Complex;  {120-degree shift constant}
   SQRT2              :Double;
   SQRT3              :Double;
   InvSQRT3           :Double;
   InvSQRT3x1000      :Double;
   SolutionAbort      :Boolean;
   InShowResults      :Boolean;
   Redirect_Abort     :Boolean;
   In_Redirect        :Boolean;
   DIFilesAreOpen     :Boolean;
   AutoShowExport     :Boolean;
   SolutionWasAttempted :Boolean;

   GlobalHelpString   :String;
   GlobalPropertyValue:String;
   GlobalResult       :String;
   LastResultFile     :String;
   VersionString      :String;

   LogQueries         :Boolean;
   QueryFirstTime     :Boolean;
   QueryLogFileName   :String;
   QueryLogFile       :TextFile;

   DefaultEditor    :String;     // normally, Notepad
   DefaultFontSize  :Integer;
   DefaultFontName  :String;
   //DefaultFontStyles :TFontStyles;
   DSSFileName      :String;     // Name of current exe or DLL
   DSSDirectory     :String;     // where the current exe resides
   StartupDirectory :String;     // Where we started
   DataDirectory    :String;     // used to be DSSDataDirectory
   OutputDirectory  :String;     // output files go here, same as DataDirectory if writable
   CircuitName_     :String;     // Name of Circuit with a "_" appended

   DefaultBaseFreq  :Double;
   DaisySize        :Double;

   // Some commonly used classes   so we can find them easily
   LoadShapeClass     :TLoadShape;
   TShapeClass        :TTshape;
   PriceShapeClass    :TPriceShape;
//   XYCurveClass       :TXYCurve;
   GrowthShapeClass   :TGrowthShape;
   SpectrumClass      :TSpectrum;
   SolutionClass      :TDSSClass;
   EnergyMeterClass   :TEnergyMeter;
   // FeederClass        :TFeeder;
   MonitorClass       :TDSSMonitor;
   SensorClass        :TSensor;
//   TCC_CurveClass     :TTCC_Curve;
   WireDataClass      :TWireData;
   CNDataClass        :TCNData;
   TSDataClass        :TTSData;
   LineSpacingClass   :TLineSpacing;
//   StorageClass       :TStorage;
//   PVSystemClass      :TPVSystem;
   // Deleted ---    VVControlClass     :TVVControl;
  // InvControlClass     :TInvControl;

   EventStrings: TStringList;
   SavedFileList:TStringList;

   DSSClassList       :TNPointerList; // pointers to the base class types
   ClassNames         :THashList;

   UpdateRegistry     :Boolean;  // update on program exit

PROCEDURE DoErrorMsg(Const S, Emsg, ProbCause :String; ErrNum:Integer);
PROCEDURE DoSimpleMsg(Const S :String; ErrNum:Integer);

PROCEDURE ClearAllCircuits;

PROCEDURE SetObject(const param :string);
FUNCTION  SetActiveBus(const BusName:String):Integer;
PROCEDURE SetDataPath(const PathName:String);

PROCEDURE MakeNewCircuit(Const Name:String);

PROCEDURE AppendGlobalResult(Const s:String);
PROCEDURE AppendGlobalResultCRLF(const S:String);  // Separate by CRLF

PROCEDURE ResetQueryLogFile;
PROCEDURE WriteQueryLogFile(Const Prop, S:String);

PROCEDURE WriteDLLDebugFile(Const S:String);

//PROCEDURE ReadDSS_Registry;
//PROCEDURE WriteDSS_Registry;

//FUNCTION IsDSSDLL(Fname:String):Boolean;

Function GetOutputDirectory:String;

implementation
uses
  //SHFolder,
solution,
Executive;
FUNCTION GetDefaultDataDirectory: String;
Var
  ThePath:Array[0..MAX_PATH] of char;
Begin
  writeln('1');
//  FillChar(ThePath, SizeOF(ThePath), #0);
//  SHGetFolderPath (0, CSIDL_PERSONAL, 0, 0, ThePath);
//  Result := ThePath;
End;

FUNCTION GetDefaultScratchDirectory: String;
Var
  ThePath:Array[0..MAX_PATH] of char;
Begin
  writeln('2');
//  FillChar(ThePath, SizeOF(ThePath), #0);
//  SHGetFolderPath (0, CSIDL_LOCAL_APPDATA, 0, 0, ThePath);
//  Result := ThePath;
End;

function GetOutputDirectory:String;
begin
  Result := OutputDirectory;
end;

//----------------------------------------------------------------------------
PROCEDURE DoErrorMsg(Const S, Emsg, ProbCause:String; ErrNum:Integer);

VAR
    Msg:String;
    Retval:Integer;
Begin
  writeln('doerrormsg');

 {    Msg := Format('Error %d Reported From OpenDSS Intrinsic Function: ', [Errnum])+ CRLF  + S
             + CRLF   + CRLF + 'Error Description: ' + CRLF + Emsg
             + CRLF   + CRLF + 'Probable Cause: ' + CRLF+ ProbCause;

     If Not NoFormsAllowed Then Begin

         If In_Redirect Then
         Begin
           RetVal := DSSMessageDlg(Msg, FALSE);
           If RetVal = -1 Then Redirect_Abort := True;
         End
         Else
           DSSMessageDlg(Msg, TRUE);

     End;

     LastErrorMessage := Msg;
     ErrorNumber := ErrNum;
     AppendGlobalResultCRLF(Msg);     }
End;
//----------------------------------------------------------------------------
PROCEDURE AppendGlobalResultCRLF(const S:String);

Begin
    If Length(GlobalResult) > 0
    THEN GlobalResult := GlobalResult + CRLF + S
    ELSE GlobalResult := S;
End;


//----------------------------------------------------------------------------
PROCEDURE DoSimpleMsg(Const S:String; ErrNum:Integer);

VAR
    Retval:Integer;
Begin
  writeln('dosimplemsg');

{      IF Not NoFormsAllowed Then Begin
       IF   In_Redirect
       THEN Begin
         RetVal := DSSMessageDlg(Format('(%d) OpenDSS %s%s', [Errnum, CRLF, S]), FALSE);
         IF   RetVal = -1
         THEN Redirect_Abort := True;
       End
       ELSE
         DSSInfoMessageDlg(Format('(%d) OpenDSS %s%s', [Errnum, CRLF, S]));
      End;

     LastErrorMessage := S;
     ErrorNumber := ErrNum;
     AppendGlobalResultCRLF(S);   }
End;
//----------------------------------------------------------------------------
PROCEDURE SetObject(const param :string);

{Set object active by name}

VAR
   dotpos :Integer;
   ObjName, ObjClass :String;

Begin

      // Split off Obj class and name
      dotpos := Pos('.', Param);
      CASE dotpos OF
         0:ObjName := Copy(Param, 1, Length(Param));  // assume it is all name; class defaults
      ELSE Begin
           ObjClass := Copy(Param, 1, dotpos-1);
           ObjName  := Copy(Param, dotpos+1, Length(Param));
           End;
      End;

      IF Length(ObjClass) > 0 THEN SetObjectClass(ObjClass);

      ActiveDSSClass := DSSClassList.Get(LastClassReferenced);
      IF ActiveDSSClass <> Nil THEN
      Begin
        IF Not ActiveDSSClass.SetActive(Objname) THEN
        Begin // scroll through list of objects untill a match
          DoSimpleMsg('Error! Object "' + ObjName + '" not found.'+ CRLF + parser.CmdString, 904);
        End
        ELSE
        With ActiveCircuit Do
        Begin
           CASE ActiveDSSObject.DSSObjType OF
                DSS_OBJECT: ;  // do nothing for general DSS object

           ELSE Begin   // for circuit types, set ActiveCircuit Element, too
                 ActiveCktElement := ActiveDSSClass.GetActiveObj;
                End;
           End;
        End;
      End
      ELSE
        DoSimpleMsg('Error! Active object type/class is not set.', 905);

End;

//----------------------------------------------------------------------------
FUNCTION SetActiveBus(const BusName:String):Integer;


Begin

   // Now find the bus and set active
   Result := 0;

   WITH ActiveCircuit Do
     Begin
        If BusList.ListSize=0 Then Exit;   // Buslist not yet built
        ActiveBusIndex := BusList.Find(BusName);
        IF   ActiveBusIndex=0 Then
          Begin
            Result := 1;
            AppendGlobalResult('SetActiveBus: Bus ' + BusName + ' Not Found.');
          End;
     End;

End;

PROCEDURE ClearAllCircuits;

Begin

    ActiveCircuit := Circuits.First;
     WHILE ActiveCircuit<>nil DO
     Begin
        ActiveCircuit.Free;
        ActiveCircuit := Circuits.Next;
     End;
    Circuits.Free;
    Circuits := TNPointerList.Create(2);   // Make a new list of circuits
    NumCircuits := 0;

    // Revert on key global flags to Original States
    DefaultEarthModel     := DERI;
    LogQueries            := FALSE;
    MaxAllocationIterations := 2;

End;



PROCEDURE MakeNewCircuit(Const Name:String);

//Var
//   handle :Integer;
Var
    S:String;

Begin


     If NumCircuits <= MaxCircuits - 1 Then
     Begin
         ActiveCircuit := TDSSCircuit.Create(Name);
         ActiveDSSObject := ActiveSolutionObj;
         {*Handle := *} Circuits.Add(ActiveCircuit);
         Inc(NumCircuits);
         S := Parser.Remainder;    // Pass remainder of string on to vsource.
         {Create a default Circuit}
         SolutionABort := FALSE;
         {Voltage source named "source" connected to SourceBus}
         DSSExecutive.Command := 'New object=vsource.source Bus1=SourceBus ' + S;  // Load up the parser as if it were read in
     End
     Else
     Begin
         DoErrorMsg('MakeNewCircuit',
                    'Cannot create new circuit.',
                    'Max. Circuits Exceeded.'+CRLF+
                    '(Max no. of circuits='+inttostr(Maxcircuits)+')', 906);
     End;
End;


PROCEDURE AppendGlobalResult(Const S:String);

// Append a string to Global result, separated by commas

Begin
    If Length(GlobalResult)=0 Then
        GlobalResult := S
    Else
        GlobalResult := GlobalResult + ', ' + S;
End;

PROCEDURE WriteDLLDebugFile(Const S:String);

Begin

        AssignFile(DLLDebugFile, OutputDirectory + 'DSSDLLDebug.TXT');
        If DLLFirstTime then Begin
           Rewrite(DLLDebugFile);
           DLLFirstTime := False;
        end
        Else Append( DLLDebugFile);
        Writeln(DLLDebugFile, S);
        CloseFile(DLLDebugFile);

End;

function IsDirectoryWritable(const Dir: String): Boolean;
var
  TempFile: array[0..MAX_PATH] of Char;
begin
writeln('no');
end;

PROCEDURE SetDataPath(const PathName:String);
var
  ScratchPath: String;
// Pathname may be null
BEGIN
  if (Length(PathName) > 0) and not DirectoryExists(PathName) then Begin
  // Try to create the directory
    if not CreateDir(PathName) then Begin
      DosimpleMsg('Cannot create ' + PathName + ' directory.', 907);
      Exit;
    End;
  End;

  DataDirectory := PathName;

  // Put a \ on the end if not supplied. Allow a null specification.
  If Length(DataDirectory) > 0 Then Begin
    ChDir(DataDirectory);   // Change to specified directory
    If DataDirectory[Length(DataDirectory)] <> '\' Then DataDirectory := DataDirectory + '\';
  End;

  // see if DataDirectory is writable. If not, set OutputDirectory to the user's appdata
  if IsDirectoryWritable(DataDirectory) then begin
    OutputDirectory := DataDirectory;
  end else begin
    ScratchPath := GetDefaultScratchDirectory + '\' + ProgramName + '\';
    if not DirectoryExists(ScratchPath) then CreateDir(ScratchPath);
    OutputDirectory := ScratchPath;
  end;
END;
PROCEDURE ResetQueryLogFile;
Begin
     QueryFirstTime := TRUE;
End;


PROCEDURE WriteQueryLogfile(Const Prop, S:String);

{Log file is written after a query command if LogQueries is true.}

Begin

  TRY
        QueryLogFileName :=  OutputDirectory + 'QueryLog.CSV';
        AssignFile(QueryLogFile, QueryLogFileName);
        If QueryFirstTime then
        Begin
             Rewrite(QueryLogFile);  // clear the file
             Writeln(QueryLogFile, 'Time(h), Property, Result');
             QueryFirstTime := False;
        end
        Else Append( QueryLogFile);

        Writeln(QueryLogFile,Format('%.10g, %s, %s',[ActiveCircuit.Solution.DynaVars.dblHour, Prop, S]));
        CloseFile(QueryLogFile);
  EXCEPT
        On E:Exception Do DoSimpleMsg('Error writing Query Log file: ' + E.Message, 908);
  END;

End;
initialization

   {Various Constants and Switches}

   CALPHA                := Cmplx(-0.5, -0.866025); // -120 degrees phase shift
   SQRT2                 := Sqrt(2.0);
   SQRT3                 := Sqrt(3.0);
   InvSQRT3              := 1.0/SQRT3;
   InvSQRT3x1000         := InvSQRT3 * 1000.0;
   CmdResult             := 0;
   DIFilesAreOpen        := FALSE;
   ErrorNumber           := 0;
   ErrorPending          := FALSE;
   GlobalHelpString      := '';
   GlobalPropertyValue   := '';
   LastResultFile        := '';
   In_Redirect           := FALSE;
   InShowResults         := FALSE;
   //IsDLL                 := FALSE;
   LastCommandWasCompile := FALSE;
   LastErrorMessage      := '';
   MaxCircuits           := 1;  //  This version only allows one circuit at a time
   MaxAllocationIterations := 2;
   SolutionAbort         := FALSE;
   AutoShowExport        := FALSE;
   SolutionWasAttempted  := FALSE;

   DefaultBaseFreq       := 60.0;
   DaisySize             := 1.0;
   DefaultEarthModel     := DERI;
   ActiveEarthModel      := DefaultEarthModel;

   {Initialize filenames and directories}

   ProgramName      := 'opendss';//'OpenDSS';
   //DSSFileName      := GetDSSExeFile;
   DSSDirectory     := '~';//ExtractFilePath(DSSFileName);mod by ju
   // want to know if this was built for 64-bit, not whether running on 64 bits
   // (i.e. we could have a 32-bit build running on 64 bits; not interested in that
//{$IFDEF CPUX64}
//   VersionString    := 'Version ' + GetDSSVersion + ' (64-bit build)';
//{$ELSE ! CPUX86}
//   VersionString    := 'Version ' + GetDSSVersion + ' (32-bit build)';
//{$ENDIF}
   StartupDirectory := '~/workspace';
   //GetCurrentDir+'\';
   //SetDataPath (GetDefaultDataDirectory + '\' + ProgramName + '\');

 //  DSS_Registry     := TIniRegSave.Create('\Software\' + ProgramName);

   AuxParser       := TParser.Create;
   DefaultEditor   := 'NotePad';
   DefaultFontSize := 8;
   DefaultFontName := 'MS Sans Serif';

   NoFormsAllowed  := FALSE;

   EventStrings    := TStringList.Create;
   SavedFileList   := TStringList.Create;

   LogQueries        := FALSE;
   QueryLogFileName  := '';
   UpdateRegistry    := TRUE;


   //WriteDLLDebugFile('DSSGlobals');

Finalization

  // Dosimplemsg('Enter DSSGlobals Unit Finalization.');
  Auxparser.Free;

  EventStrings.Free;
  SavedFileList.Free;

  With DSSExecutive Do If RecorderOn Then Recorderon := FALSE;

  DSSExecutive.Free;  {Writes to Registry}
//  DSS_Registry.Free;  {Close Registry}



end.

