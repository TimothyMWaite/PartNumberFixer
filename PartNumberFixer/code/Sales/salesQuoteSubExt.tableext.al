tableextension 50105 SalesLineExt extends "Sales Line"
{
    fields
    {
        field(50104; PartNumber; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(50105; ItemType; Enum ItemTypes)
        {
            DataClassification = ToBeClassified;
        }
        field(50123; LeadTime; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50106; ShipmentNumber; Integer)
        {
            DataClassification = ToBeClassified;
        }
        // Add changes to table fields here
    }
    keys
    {
        key(SK; ShipmentNumber)
        {
            // Secondary key based on the ShipmentNumber
        }
    }
    fieldgroups
    {
        addlast(DropDown; "Line No.")
        {
            // Add the "Line No." field to the DropDown field group
        }
    }
    trigger OnDelete()
    var
        OptionLineRecord: Record OptionLine;
    begin
        // Delete all related OptionLine records when a Sales Line is deleted
        OptionLineRecord.Reset();
        OptionLineRecord.SetFilter(DocumentID, "Document No.");
        OptionLineRecord.SetRange(LineNumber, "Line No.");
        OptionLineRecord.DeleteAll();
    end;

    procedure GetPartNumber(): Text[200]
    var
        OptionLineRecord: Record OptionLine;
        OptionDesignatorRecord: Record "Option Designators";
        PriceIncrease: Decimal;
        PrefixSelection, SuffixSelection : Text[200];
        BasePartNumber: Text[100];
    begin
        if "Line No." <> 0 then begin
            PrefixSelection := '';
            SuffixSelection := '';
            BasePartNumber := GetItem().PartNumber;
            PriceIncrease := 0;

            // Process prefix selections
            OptionDesignatorRecord.Reset();
            OptionLineRecord.Reset();
            OptionLineRecord.SetFilter(DocumentID, "Document No.");
            OptionLineRecord.SetRange(LineNumber, "Line No.");
            OptionLineRecord.SetCurrentKey(PrefixOrder);
            OptionLineRecord.SetAscending(PrefixOrder, true);
            if OptionLineRecord.FindSet() then begin
                repeat
                    if OptionLineRecord.PreSelection <> '' then begin
                        PrefixSelection += OptionLineRecord.PreSelection;
                        OptionDesignatorRecord.Reset();
                        if OptionDesignatorRecord.Get(OptionLineRecord.PreSelection) then begin
                            PriceIncrease += OptionDesignatorRecord.PriceChange;
                        end;
                    end;
                until OptionLineRecord.Next() = 0;
            end;

            // Process suffix selections
            Rec.Reset();
            OptionLineRecord.SetFilter(DocumentID, "Document No.");
            OptionLineRecord.SetRange(LineNumber, "Line No.");
            OptionLineRecord.SetCurrentKey(SuffixOrder);
            OptionLineRecord.SetAscending(SuffixOrder, true);
            if OptionLineRecord.FindSet() then begin
                repeat
                    if OptionLineRecord.SuffixSelection <> '' then begin
                        SuffixSelection += OptionLineRecord.SuffixSelection;
                        OptionDesignatorRecord.Reset();
                        if OptionDesignatorRecord.Get(OptionLineRecord.SuffixSelection) then begin
                            PriceIncrease += OptionDesignatorRecord.PriceChange;
                        end;
                    end;
                    OptionLineRecord.Modify(false);
                until OptionLineRecord.Next() = 0;
            end;

            PreSelections := PrefixSelection;
            SuffixSelections := SuffixSelection;
            exit(PrefixSelection + BasePartNumber + SuffixSelection);
        end;
    end;

    procedure HasOptions(): Boolean
    var
        OptionLineRecord: Record OptionLine;
    begin
        // Check if there are any options associated with the sales line
        OptionLineRecord.Reset();
        OptionLineRecord.SetFilter(DocumentID, "Document No.");
        OptionLineRecord.SetRange(LineNumber, "Line No.");
        exit(OptionLineRecord.FindSet());
    end;

    procedure IsNewRecord(PartNumberToCheck: Text[200]): Boolean
    begin
        // Check if the part number is new (not contained in the current part number)
        exit((not PartNumber.Contains(PartNumberToCheck)) OR (PartNumberToCheck = ''));
    end;

    procedure IsVariableUsed(): Boolean
    begin
        // Check if a variable has been used
        exit(VariableUsed);
    end;

    procedure SetVariableUsed(IsUsed: Boolean)
    begin
        // Set the variable usage flag
        VariableUsed := IsUsed;
    end;

    procedure GetBasePartNumber(): Text[100]
    begin
        // Retrieve the base part number from the item or the sales line
        if "No." <> '' then begin
            exit(GetItem().PartNumber);
        end else begin
            if PartNumber <> '' then begin
                exit(PartNumber);
            end;
        end;
    end;

    procedure addOptionsToPartNo(BasePartNumber: Text[100]): Text[200]
    begin
        // Combine the base part number with the selected options
        exit(PreSelections + BasePartNumber + SuffixSelections);
    end;

    var
        VariableUsed: Boolean;
        PreSelections, SuffixSelections : Text[50];
}
