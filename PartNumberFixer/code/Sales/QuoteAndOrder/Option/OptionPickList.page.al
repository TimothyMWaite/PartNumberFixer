page 50136 OptionLineList
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = OptionLine;

    layout
    {
        area(Content)
        {
            repeater("Options")
            {
                field(LineNumber; Rec.LineNumber)
                {
                    ApplicationArea = All;
                    Visible = true;
                    TableRelation = "Sales Line"."Line No.";
                }
                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field(DocumentNumber; Rec.DocumentID)
                {
                    ApplicationArea = All;
                    Visible = true;
                    TableRelation = "Sales Line"."Document No.";
                }
                field(OptionID; Rec.OptionID)
                {
                    ApplicationArea = All;
                    Visible = true;
                    TableRelation = Option.Id where(Name = field(OptionName));
                }
                field(OptionName; Rec.OptionName)
                {
                    ApplicationArea = All;
                    Caption = 'Option';
                    TableRelation = Option.Name where("Item Type" = field(ItemType));
                    DrillDownPageId = OptionList;
                    DrillDown = true;
                    LookupPageId = OptionList;
                    Lookup = true;

                    trigger OnValidate()
                    var
                        OptionRecord: Record Option;
                    begin
                        if Rec.Id = 0 then begin
                            Initialize();
                            Rec.Insert(false);
                        end;
                        OptionRecord.SetFilter(Name, Rec.OptionName);
                        if OptionRecord.FindFirst() then begin
                            Rec.OptionID := OptionRecord.Id;
                            Rec.Modify(false);
                        end;
                    end;
                }

                // Selection fields
                field(StartSelection; Rec.PreSelection)
                {
                    ApplicationArea = All;
                    Caption = 'Change at the start of the Part Number';
                    ToolTip = 'Select as many changes to the start of the part number as needed. Keep in mind that for some of these you may also need to select one of the end of part number options. If they are not showing in the correct order, you can edit the option to fix this or talk to Tim.';
                    TableRelation =
                        if (OptionName = const('')) "Option Designators".Designator where(itemType = field(ItemType), AtFront = Const(true))
                    else
                    "Option Designators".Designator where(itemType = field(ItemType), OptionID = field(OptionID), AtFront = Const(true));
                    LookupPageId = "Option Designators";

                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        UpdatePartNumber();
                    end;

                    trigger OnValidate()
                    var
                        OptionDesignatorRecord: Record "Option Designators";
                        OptionRecord: Record Option;
                    begin
                        if Rec.Id = 0 then
                            Initialize();

                        // Get the designator and update relevant fields
                        OptionDesignatorRecord := Rec.GetDesignator(true);
                        if (Rec.OptionID <> OptionDesignatorRecord.OptionID) AND (OptionDesignatorRecord.OptionID <> 0) then begin
                            Rec.OptionID := OptionDesignatorRecord.OptionID;
                        end;
                        Rec.PreID := OptionDesignatorRecord.Id;
                        Rec.IsPreVariable := OptionDesignatorRecord.Variable;
                        Rec.PrefixOrder := OptionDesignatorRecord.Order;
                        Rec.PreCost := OptionDesignatorRecord.PriceChange;

                        if OptionRecord.Get(OptionDesignatorRecord.OptionID) then
                            Rec.OptionName := OptionRecord.Name;

                        if Rec.Modify(false) then begin
                            UpdatePartNumber();
                            UpdatePricing();
                        end else begin
                            Error('Cannot edit option line. Please try again, and if it does not work, contact Tim.');
                        end;

                        CurrPage.Update(true);
                    end;
                }

                field(PartNumber; Rec.PartNumber)
                {
                    ApplicationArea = All;
                    Enabled = Rec.OptionName <> '';
                    Editable = false;
                    Caption = 'Part Number';
                }

                field(EndSelection; Rec.SuffixSelection)
                {
                    ApplicationArea = All;
                    Caption = 'Change at the end of the Part Number';
                    ToolTip = 'Select as many changes to the end of the part number as needed. If they are not showing in the correct order, you can edit the option to fix this or talk to Tim.';
                    TableRelation = "Option Designators".Designator where(itemType = field(ItemType), OptionID = field(OptionID), AtFront = Const(false));
                    LookupPageId = "Option Designators";

                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        UpdatePartNumber();
                    end;

                    trigger OnValidate()
                    var
                        OptionDesignatorRecord: Record "Option Designators";
                        OptionRecord: Record Option;
                    begin
                        if Rec.Id = 0 then
                            Initialize();

                        // Get the designator and update relevant fields
                        OptionDesignatorRecord := Rec.GetDesignator(false);
                        if (Rec.OptionID <> OptionDesignatorRecord.OptionID) AND (OptionDesignatorRecord.OptionID <> 0) then begin
                            Rec.OptionID := OptionDesignatorRecord.OptionID;
                            if OptionRecord.Get(OptionDesignatorRecord.OptionID) then
                                Rec.OptionName := OptionRecord.Name;
                        end;
                        Rec.SuffixID := OptionDesignatorRecord.Id;
                        Rec.IsSuffixVariable := OptionDesignatorRecord.Variable;
                        Rec.SuffixOrder := OptionDesignatorRecord.Order;
                        Rec.SuffixCost := OptionDesignatorRecord.PriceChange;

                        if Rec.Modify(false) then begin
                            UpdatePartNumber();
                            UpdatePricing();
                        end else begin
                            Error('Cannot edit option line. Please try again, and if it does not work, contact Tim.');
                        end;

                        CurrPage.Update(true);
                    end;
                }
            }
        }
    }

    actions { }

    trigger OnOpenPage()
    var
        OptionRecord: Record Option;
        OptionLineRecord: Record OptionLine;
        PartNumber: Text;
    begin
        OptionRecord.SetRange("Item Type", SalesLineRecord.GetItem()."Item Type");
        if OptionRecord.FindSet() then begin
            repeat
                if OptionRecord.Required then begin
                    OptionLineRecord.Reset();
                    OptionLineRecord.SetFilter(DocumentID, SalesLineRecord."Document No.");
                    OptionLineRecord.SetRange(OptionID, OptionRecord.Id);
                    OptionLineRecord.SetRange(LineNumber, SalesLineRecord."Line No.");
                    if not OptionLineRecord.FindFirst() then begin
                        OptionLineRecord.Init();
                        OptionLineRecord.Id := OptionLineRecord.GetNewID();
                        OptionLineRecord.DocumentID := SalesLineRecord."Document No.";
                        OptionLineRecord.LineNumber := SalesLineRecord."Line No.";
                        OptionLineRecord.OptionID := OptionRecord.Id;
                        OptionLineRecord.PartNumber := SalesLineRecord.GetItem().PartNumber;
                        OptionLineRecord.OptionName := OptionRecord.Name;
                        OptionLineRecord.PreSelection := '';
                        OptionLineRecord.SuffixSelection := '';
                        OptionLineRecord.Insert(false);
                    end;
                end;
            until OptionRecord.Next() = 0;
        end;

        OptionLineRecord.Reset();
        OptionLineRecord.SetFilter(DocumentID, SalesLineRecord."Document No.");
        OptionLineRecord.SetRange(LineNumber, SalesLineRecord."Line No.");
        if OptionLineRecord.FindSet() then begin
            CurrPage.SetRecord(OptionLineRecord);
            PartNumber := SalesLineRecord.GetPartNumber();
            repeat
                if OptionLineRecord.PartNumber <> PartNumber then begin
                    OptionLineRecord.PartNumber := PartNumber;
                    OptionLineRecord.Modify(false);
                end;
            until OptionLineRecord.Next() = 0;
        end else begin
            Initialize();
        end;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Initialize();
    end;

    procedure GetPartNumber(): Text[200]
    begin
        exit(Rec.PartNumber);
    end;

    procedure Initialize()
    begin
        Rec.Init();
        Rec.Id := Rec.GetNewID();
        Rec.DocumentID := SalesLineRecord."Document No.";
        Rec.LineNumber := SalesLineRecord."Line No.";
        Rec.Insert(false);
        CurrPage.Update(false);
    end;

    procedure SetSalesLine(SalesLine: Record "Sales Line")
    begin
        SalesLineRecord := SalesLine;
        ItemRecord := SalesLine.GetItem();
        Rec.ItemType := ItemRecord."Item Type";
    end;

    procedure UpdatePartNumber()
    var
        OptionLineRecord: Record OptionLine;
        OptionDesignatorRecord: Record "Option Designators";
        SalesLineRecord: Record "Sales Line";
        FinalPartNumber: Text[200];
    begin
        if SalesLineRecord."Line No." <> 0 then begin
            FinalPartNumber := SalesLineRecord.GetPartNumber();
            if Rec.OptionID <> 0 then
                Rec.Modify(false);

            OptionLineRecord.Reset();
            OptionLineRecord.SetFilter(DocumentID, Rec.DocumentID);
            OptionLineRecord.SetRange(LineNumber, Rec.LineNumber);
            if OptionLineRecord.FindSet() then begin
                repeat
                    OptionLineRecord.PartNumber := FinalPartNumber;
                    OptionLineRecord.Modify(false);
                until OptionLineRecord.Next() = 0;
            end;

            SalesLineRecord.PartNumber := FinalPartNumber;
            Rec.PartNumber := FinalPartNumber;

            if not SalesLineRecord.Insert(false) then begin
                SalesLineRecord.Modify(false);
            end;

            CurrPage.Update(false);
        end;
    end;

    procedure UpdatePricing()
    var
        OptionLineRecord: Record OptionLine;
    begin
        TotalCostIncrease := 0;
        OptionLineRecord.Reset();
        OptionLineRecord.SetFilter(DocumentID, Rec.DocumentID);
        OptionLineRecord.SetRange(LineNumber, Rec.LineNumber);
        if OptionLineRecord.FindSet() then begin
            repeat
                TotalCostIncrease += OptionLineRecord.PreCost + OptionLineRecord.SuffixCost;
            until OptionLineRecord.Next() = 0;
        end;
        SalesLineRecord."Unit Price" := SalesLineRecord.GetItem()."Unit Price" + TotalCostIncrease;
        SalesLineRecord.Modify(false);
    end;

    var
        ItemRecord: Record Item;
        SalesLineRecord: Record "Sales Line";
        TotalCostIncrease: Decimal;
        FinalPartNumber: Text[200];
}
