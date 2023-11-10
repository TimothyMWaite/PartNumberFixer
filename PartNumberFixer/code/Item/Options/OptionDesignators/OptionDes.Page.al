page 50118 "Option Suffixs"
{
    PageType = ListPart;
    SourceTable = "Option Suffix";
    ApplicationArea = All;
    ModifyAllowed = true;
    MultipleNewLines = false;

    layout
    {
        area(content)
        {
            usercontrol("CombinedControl"; CombinedControl)
            {
                trigger openAddOptions()
                var
                begin
                    MyModalPage.SetTableView(TempRec);
                    if MyModalPage.RunModal = Action::OK then begin
                        updateControl();
                        Clear(MyModalPage);
                    end;
                end;

            }
            repeater("Suffix Designators")
            {
                field("Suffix Designator"; Rec."Suffix Designator")
                {
                    ApplicationArea = All;
                    Caption = 'Change at end of PN';
                    trigger OnValidate()
                    var

                    begin
                        rec.OptionID := optionRec.Id;
                        addToList();

                    end;

                }
                field(AssemblyChange; Rec.AssemblyChange)
                {
                    ApplicationArea = All;
                    Enabled = (Rec."Suffix Designator" <> '');
                    TableRelation = "Option Assembly Line".ID;
                    Lookup = false;
                    DrillDown = true;
                    DrillDownPageId = "Option Assembly List";

                    trigger OnDrillDown()
                    begin
                        rec.AssemblyChange := runAssemblyList(false, optionRec);
                        rec.Modify();
                    end;
                }
                field("Active"; Rec.show)
                {
                    ApplicationArea = All;
                    Enabled = (Rec."Suffix Designator" <> '');
                    trigger OnValidate()
                    var
                        sRec: Record "Option Suffix";
                        sl: Record SPList;
                    begin
                        // MyModalPage.addFromCurrentRec(rec);
                        sRec.Reset();
                        sRec.SetFilter(OptionID, Format(rec.OptionID));
                        sRec.SetRange(show, true);
                        if rec.show then begin

                            if sRec.FindSet() then begin
                                repeat
                                    if sRec."Suffix Designator" <> rec."Suffix Designator" then begin
                                        sRec.show := false;
                                        if sRec.Modify() then begin
                                            if sl.Get(Format(sRec.OptionID) + sRec."Suffix Designator") then begin
                                                sl.active := false;
                                                sl.Modify();
                                            end;
                                        end;
                                    end;
                                until sRec.Next() = 0;
                            end;
                        end;

                        addToList();
                        CurrPage.CombinedControl.updateValues(MyModalPage.getPreText(optionRec.Id), MyModalPage.getSufText(optionRec.Id));

                    end;
                }
                field(OptionID; Rec.OptionID)
                {
                    ApplicationArea = All;

                }
            }




        }
    }
    actions
    {
        area(Processing)
        {


            action("Create Table")
            {
                trigger OnAction()
                var
                    OldOption, NewOption : Record "Option";
                    OptionCount: Integer;
                begin
                    // Save the current option
                    CurrPage.CombinedControl.addControl();
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        if not tableSet then begin
            createCustomTable();
            updateControl();

            tableSet := true;
        end;
        rec.show := false;
    end;

    procedure toggleCN()
    begin
        CurrPage.CombinedControl.toggleCN();
    end;

    procedure updateControl()
    begin


        CurrPage.CombinedControl.updateValues(MyModalPage.getPreText(optionRec.Id), MyModalPage.getSufText(optionRec.Id));
        Clear(MyModalPage);
    end;

    procedure createCustomTable()
    var
        oRec: Record Option;
        sRec: Record "Option Suffix";
    begin

        CurrPage.CombinedControl.addControl();

    end;

    procedure setTableSet()
    begin
        tableSet := true;
    end;

    procedure setOptionRec(o: Record Option)
    var
    begin
        optionRec := o;
    end;

    procedure addToList()
    var
        SPRec, sp : Record SPList;
        sRec: Record "Option Suffix";
        LastID: Integer;
    begin
        if SPRec.Get(Format(rec.OptionID) + rec."Suffix Designator") then begin
            SPRec.Designator := rec."Suffix Designator";
            SPRec.Order := optionRec."Prefix Order";
            SPRec.active := rec.show;
            SPRec.prefix := false;
            SPRec.Modify();
        end else begin
            SPRec.Init();
            SPRec.ID := format(rec.OptionID) + rec."Suffix Designator";
            SPRec.Designator := rec."Suffix Designator";
            SPRec.Order := optionRec."Prefix Order";
            SPRec.active := rec.show;
            SPRec.prefix := false;
            SPRec.OptionID := optionRec.Id;
            if not SPRec.Insert() then begin

            end;
        end;

        updateControl();
    end;

    procedure runAssemblyList(pre: Boolean; oRec: Record Option): Text[50]
    var
        OAPage: Page "Option Assembly List";
        ARec: Record "Option Assembly Line";
    begin

        if pre then begin
            if ARec.get(Format(oRec.Id) + oRec."Prefix Designator" + '1') then begin
                OAPage.SetTableView(ARec);
            end else begin
                ARec.Init();
                ARec.ID := Format(oRec.Id) + oRec."Prefix Designator" + '1';
                ARec."Option ID" := oRec.Id;
                ARec."Line No." := 1;
                ARec.Designator := oRec."Prefix Designator";
                ARec.Insert();
                OAPage.SetTableView(ARec);
            end;

        end else begin
            if ARec.get(Format(oRec.Id) + rec."Suffix Designator" + '1') then begin
                OAPage.SetTableView(ARec);

            end else begin
                ARec.Init();
                ARec.ID := Format(oRec.Id) + rec."Suffix Designator" + '1';
                ARec."Option ID" := oRec.Id;
                ARec.Designator := rec."Suffix Designator";
                ARec."Line No." := 1;
                ARec.Insert();
                OAPage.SetTableView(ARec);
            end;
        end;
        if not pre then
            rec.AssemblyChange := ARec.ID;
        Commit();
        if OAPage.RunModal = Action::OK then begin

            rec.Modify();
            if pre then
                exit(ARec.ID);
        end;
    end;

    procedure updateOrder()
    var

        sRec: Record "Option Suffix";
        sl: Record SPList;
    begin
        if rec."Suffix Order" <> optionRec."Suffix Order" then begin
            sRec.Reset();
            sRec.SetFilter(OptionID, Format(rec.OptionID));
            if sRec.FindSet() then begin
                repeat
                    sRec."Suffix Order" := optionRec."Suffix Order";
                    sRec.show := false;
                    sRec.Modify();
                    if sl.Get(Format(sRec.OptionID) + sRec."Suffix Designator") then begin
                        sl.Order := optionRec."Suffix Order";
                        sl.active := false;
                        sl.Modify();
                    end;
                until sRec.Next() = 0;
            end;
            updateControl();
        end;

    end;

    var
        optionRec: Record Option;
        TempRec: Record SPList temporary;
        tableSet: Boolean;
        MyModalPage: Page "SPList";


}