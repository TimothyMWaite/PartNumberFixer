page 50118 "Option Designators"
{
    PageType = ListPart;
    SourceTable = "Option Designators";
    ApplicationArea = All;
    UsageCategory = Lists;
    MultipleNewLines = false;

    layout
    {
        area(content)
        {
            usercontrol("CombinedControl"; CombinedControl)
            {
                trigger openAddOptions()
                var

                    tempRec: Record "Option Designators";
                begin
                    MyModalPage.SetTableView(TempRec);
                    if MyModalPage.RunModal = Action::OK then begin
                        updateControl();
                        Clear(MyModalPage);
                    end;
                end;

            }
            repeater("Designators")
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                    Lookup = true;
                    Visible = false;
                }
                field("Designator"; Rec."Designator")
                {
                    ApplicationArea = All;
                    Caption = 'Change to the Part Number';
                    NotBlank = true;


                    trigger OnValidate()
                    var
                        dRec: Record "Option Designators";
                        o: Record Option;
                    begin
                        if not drec.get(rec.Id) then begin
                            rec.OptionID := optionRec.Id;
                            rec.itemType := optionRec."Item Type";
                            rec.Insert(false);
                            CurrPage.CombinedControl.addControl();
                            updateControl();

                        end else begin

                            rec.Modify(true);
                            CurrPage.Update(false);

                        end;

                        // Message('%1', rec.Designator);
                    end;
                }
                field(Order; Rec.Order)
                {
                    ApplicationArea = All;
                    Enabled = rec.Designator <> '';

                    Caption = 'Order';
                    ToolTip = 'Order that the change to the part number will be added. The lower the number the closer to the base part number it will be.  You can simulate this via the Sample Part Number above.';
                    trigger OnValidate()
                    begin
                        rec.Modify(true);
                        updateControl();
                    end;
                }
                field(PriceChange; Rec.PriceChange)
                {
                    ApplicationArea = All;
                    Enabled = rec.Designator <> '';
                    Caption = 'Price Change';
                    BlankZero = true;
                    trigger OnValidate()
                    begin
                        rec.Modify(true);
                        CurrPage.Update(false);
                    end;
                }
                field(atFront; Rec.atFront)
                {
                    ApplicationArea = All;
                    Enabled = rec.Designator <> '';
                    Caption = 'Add to Front of Part Number';
                    trigger OnValidate()
                    begin
                        rec.Modify(true);
                        CurrPage.Update(false);
                    end;
                }
                field("Active"; Rec.show)
                {
                    ApplicationArea = All;
                    Enabled = (Rec."Designator" <> '');
                    Caption = 'Show in Preview';
                    trigger OnValidate()
                    var
                        sRec: Record "Option Designators";
                    begin

                        rec.Modify(true);
                        CurrPage.Update(false);

                    end;
                }
                field("Variable"; Rec.variable)
                {
                    ApplicationArea = All;
                    Enabled = rec.Designator <> '';
                    Caption = 'Variable';
                    trigger OnValidate() begin
                        Message('Make sure that the variable part of this option will not effect the assembly BOM. Use a capital X to designate the variable parts of the part number.');
                    end;

                }
                field(OptionID; Rec.OptionID)
                {
                    ApplicationArea = All;
                    TableRelation = Option.Id;
                    Visible = false;

                }
                field("AssemblyID"; assText)
                {
                    ApplicationArea = All;
                    Enabled = rec.Designator <> '';
                    Editable = false;
                    DrillDown = true;
                    DrillDownPageId = "Option Assembly List";
                    trigger OnDrillDown()
                    var
                        o: Record Option;
                    begin
                        rec.AssemblyID := runAssemblyList();
                    end;
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
    trigger OnNewRecord(bxRec: Boolean)
    begin

        if rec.Id = 0 then begin
            rec.Id := rec.getNewId();
            rec.OptionID := optionRec.Id;
        end;

    end;

    trigger OnOpenPage()
    var
        d: Record "Option Designators";
    begin

        // if not tableSet then begin
        //     createCustomTable();
        //     updateControl();
        //     tableSet := true;
        // end;
        // d.Reset();
        // d.SetFilter(OptionID, Format(optionRec.Id));
        // if not d.FindFirst() then begin
        //     rec.Init();
        //     rec.Id := rec.getNewId();
        //     rec.OptionID := optionRec.Id;
        //     rec.Insert(false);
        // end;
        assText := 'Open';
    end;


    trigger OnAfterGetCurrRecord()
    begin

        createCustomTable();
        updateControl();


    end;

    trigger OnModifyRecord(): Boolean
    begin

        // Message('OnModifyRecord');

        updateControl();

        exit(true);
    end;
    // procedure getText(oId: Integer; front: Boolean): text[500]
    // var
    //     pre: text[10];
    //     po: Integer;
    //     oRec: Record Option;
    //     sl: Record "Option Designators";
    //     added: Boolean;
    // begin
    //     PrefixField := '';
    //     SuffixField := '';
    //     sl.SetFilter(show, Format(front));
    //     if sl.FindSet() then begin
    //         repeat
    //             if sl.atFront = front then begin
    //                 PrefixField := sl.Designator + PrefixField;
    //             end else begin
    //                 SuffixField += sl.Designator;
    //             end;
    //         until sl.Next() = 0;

    //     end;
    //     // Message('%1', PrefixField);
    //     if front then
    //         exit(PrefixField)
    //     else
    //         exit(SuffixField);
    // end;

    procedure toggleCN()
    begin
        CurrPage.CombinedControl.toggleCN();
    end;

    procedure getID(): Integer
    begin
        exit(rec.ID);
    end;

    procedure updateControl()
    begin
        CurrPage.CombinedControl.updateValues(MyModalPage.getText(optionRec.Id, true), MyModalPage.getText(optionRec.Id, false));
        Clear(MyModalPage);
        CurrPage.Update(false);
    end;

    // procedure initialize(o: Record Option)
    // var
    //     d: Record "Option Designators";
    // begin
    //     d.Reset();
    //     d.SetFilter(OptionID, Format(o.Id));
    //     if not d.FindFirst() then begin
    //         rec.Init();
    //         rec.Id := rec.getNewId();
    //         if optionRec.Id <> 0 then begin
    //             rec.OptionID := optionRec.Id;
    //         end;
    //         rec.Insert(false);
    //     end;
    //     assText := 'Open';
    // end;

    procedure createCustomTable()
    var
    begin
        if not tableSet then begin
            CurrPage.CombinedControl.addControl();
            MyModalPage.setOptionId(optionRec.Id);
            tableSet := true;
        end;
    end;

    procedure setTableSet()
    begin
        tableSet := true;
    end;

    procedure setOptionRec(o: Record Option)
    var
    begin
        optionRec := o;
        rec.OptionID := o.Id;


    end;

    // procedure addToList()
    // var
    //     SPRec, sp : Record SPList;
    //     sRec: Record "Option Designators";
    //     LastID: Integer;
    // begin
    //     SPRec.Reset();
    //     SPRec.SetFilter(OptionID, Format(rec.OptionID));
    //     SPRec.SetFilter(Designator, rec."Designator");
    //     if SPRec.FindFirst() then begin
    //         SPRec.Designator := rec."Designator";
    //         // SPRec.Order := optionRec."Prefix Order";
    //         SPRec.active := rec.show;
    //         SPRec.inFront := false;
    //         SPRec.Modify();
    //     end else begin
    //         SPRec.Init();
    //         SPRec.ID := rec.getNewId();
    //         SPRec.Designator := rec."Designator";
    //         // SPRec.Order := optionRec."Prefix Order";
    //         SPRec.active := rec.show;
    //         SPRec.inFront := false;
    //         SPRec.OptionID := optionRec.Id;
    //         if not SPRec.Insert() then begin

    //         end;
    //     end;

    //     updateControl();
    // end;

    procedure getArecID(): Integer
    var
        a: Record "Option Assembly Line";
    begin
        if a.FindLast() then begin
            exit(a.ID + 1);
        end else begin
            exit(1000);
        end;
    end;

    procedure runAssemblyList(): Integer
    var
        OAPage: Page "Option Assembly List";
        ARec, a : Record "Option Assembly Line";
    begin
        Commit();
        ARec.Reset();
        ARec.SetRange(DesID, rec.ID);
        ARec.SetFilter("Option ID", Format(rec.OptionID));
        OAPage.setRecs(rec);
        OAPage.SetTableView(ARec);
        if OAPage.RunModal() = Action::OK then begin
            OAPage.Update();
        end;
        exit(OAPage.getID());

    end;

    // procedure updateOrder()
    // var

    //     sRec: Record "Option Designators";
    //     sl: Record SPList;
    // begin


    // end;

    var
        optionRec: Record Option;
        PrefixField, SuffixField : Text[500];
        tableSet, f : Boolean;
        MyModalPage: Page SPList;
        assText: Text[10];

}