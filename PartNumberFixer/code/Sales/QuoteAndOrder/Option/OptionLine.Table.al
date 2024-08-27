/// <summary>
/// Represents the OptionLine table in the Sales/QuoteAndOrder/Option folder.
/// </summary>
/// <remarks>
/// This table is used to store information about option lines in a sales quote or order.
/// It contains fields such as Id, PartNumber, DocumentID, OptionID, OptionName,
/// PreSelection, SuffixSelection, IsPrefix, ItemID, PrefixOrder,
/// SuffixOrder, LineNumber, PreAssemblyID, SuffixAssemblyID, and ItemType.
/// </remarks>
table 50135 OptionLine
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; PartNumber; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(3; DocumentID; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; OptionID; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(5; OptionName; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(6; PreSelection; Text[10])
        {
            DataClassification = ToBeClassified;
            // TableRelation = Option."Prefix Designator" where(Id = field(OptionID));
        }
        field(7; SuffixSelection; Text[10])
        {
            DataClassification = ToBeClassified;
            // TableRelation = "Option Suffix"."Suffix Designator" where(OptionID = field(OptionID));
        }
        field(8; IsPrefix; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; ItemID; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(10; PrefixOrder; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Option Designators"."Order" WHERE(Id = field(PreID));
        }
        field(11; SuffixOrder; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Option Designators"."Order" WHERE(Id = field(SuffixID));
        }
        field(12; LineNumber; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(13; PreAssemblyID; Integer)
        {
            DataClassification = ToBeClassified;
            // TableRelation = Option.AssemblyId where(Id = field(OptionID));
        }
        field(14; SuffixAssemblyID; Integer)
        {
            DataClassification = ToBeClassified;
            // TableRelation = "Option Suffix".AssemblyChange where(OptionID = field(OptionID), "Suffix Designator" = field(SuffixSelection));
        }
        field(15; ItemType; Enum ItemTypes)
        {
            DataClassification = ToBeClassified;
            // TableRelation = Option."Item Type" where(Id = field(OptionID));
        }
        // field(15; PriceChange; Decimal)
        // {
        //     DataClassification = ToBeClassified;
        //     TableRelation = "Item Option Line"."Price Change" where(OptionID = field(OptionID));
        // }
        field(16; PreID; Integer)
        {
            DataClassification = ToBeClassified;
            // TableRelation = Option."Prefix ID" where(Id = field(OptionID));
        }
        field(17; SuffixID; Integer)
        {
            DataClassification = ToBeClassified;
            // TableRelation = "Option Suffix"."Suffix ID" where(OptionID = field(OptionID));
        }
        field(18; IsPreVariable; Boolean)
        {
            DataClassification = ToBeClassified;
            // TableRelation = "Option Designators"."Variable" WHERE(Id = field(PreID), AtFront = cost(true));
        }
        field(19; IsSuffixVariable; Boolean)
        {
            DataClassification = ToBeClassified;
            // TableRelation = "Option Designators"."Variable" WHERE(Id = field(SuffixID));
        }
        field(20; PreCost; Decimal)
        {
            DataClassification = ToBeClassified;
            // TableRelation = "Option Designators"."Cost" WHERE(Id = field(PreID));
        }
        field(21; SuffixCost; Decimal)
        {
            DataClassification = ToBeClassified;
            // TableRelation = "Option Designators"."Cost" WHERE(Id = field(SuffixID));
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
        key(FK; DocumentID, LineNumber)
        {

        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    procedure GetNewID(): Integer
    begin
        // Generate a new ID for the OptionLine record
        Rec.Reset();
        if Rec.FindLast() then begin
            exit(Rec.Id + 1);
        end else begin
            exit(1000);
        end;
    end;

    procedure IsPreEmpty(): Boolean
    begin
        // Check if PreSelection is empty
        exit(Rec.PreSelection = '');
    end;

    procedure IsSufEmpty(): Boolean
    begin
        // Check if SuffixSelection is empty
        exit(Rec.SuffixSelection = '');
    end;

    procedure ConvertOption(OptionRecord: Record Option)
    begin
        // Convert the given Option record to an OptionLine record
        OptionRec := OptionRecord;
        OptionID := OptionRecord.Id;
        OptionName := OptionRecord.Name;
        if Id = 0 then
            Id := GetNewID();
    end;

    procedure GetOption(): Record Option
    var
        Option, TempOption : Record Option temporary;
    begin
        // Retrieve the Option record based on the OptionID
        if Rec.OptionID <> 0 then begin
            if TempOption.Get(Rec.OptionID) then begin
                exit(TempOption);
            end;
        end;
    end;

    /// <summary>
    /// Gets the Option Designator - if prefix then true, if suffix then false.
    /// </summary>
    /// <param name="IsPrefix">If true, retrieve prefix designator; otherwise, retrieve suffix designator.</param>
    /// <returns>The matching Option Designator record.</returns>
    procedure GetDesignator(IsPrefix: Boolean): Record "Option Designators"
    var
        DesignatorRecord, TempDesignator : Record "Option Designators";
    begin
        DesignatorRecord.Reset();
        if IsPrefix then begin
            if PreID <> 0 then begin
                if DesignatorRecord.Get(PreID) then begin
                    TempDesignator.Reset();
                    TempDesignator.SetFilter("Designator", PreSelection);
                    if TempDesignator.FindFirst() then begin
                        if TempDesignator.Id = DesignatorRecord.Id then begin
                            exit(DesignatorRecord);
                        end else begin
                            exit(TempDesignator);
                        end;
                    end else begin
                        if IsPreVariable then begin
                            exit(DesignatorRecord);
                        end else begin
                            Error('Non-variable option changed. %1 should be %2 - Please either edit the option to be variable or add a new option that matches your desired selection.', PreSelection, DesignatorRecord.Designator);
                        end;
                    end;
                end;
            end else begin
                exit(GetDesignatorBySelection(PreSelection));
            end;
        end else begin
            if SuffixID <> 0 then begin
                if DesignatorRecord.Get(SuffixID) then begin
                    TempDesignator.Reset();
                    TempDesignator.SetFilter("Designator", SuffixSelection);
                    if TempDesignator.FindFirst() then begin
                        if TempDesignator.Id = DesignatorRecord.Id then begin
                            exit(DesignatorRecord);
                        end else begin
                            exit(TempDesignator);
                        end;
                    end else begin
                        if IsSuffixVariable then begin
                            exit(DesignatorRecord);
                        end else begin
                            Error('Non-variable option changed. %1 should be %2 - Please either edit the option to be variable or add a new option that matches your desired selection.', SuffixSelection, DesignatorRecord.Designator);
                        end;
                    end;
                end;
            end else begin
                exit(GetDesignatorBySelection(SuffixSelection));
            end;
        end;
    end;

    /// <summary>
    /// Retrieves an Option Designator record by the given designator text.
    /// </summary>
    /// <param name="DesignatorText">The designator text to look up.</param>
    /// <returns>The matching Option Designator record.</returns>
    procedure GetDesignatorBySelection(DesignatorText: Text[10]): Record "Option Designators"
    var
        DesignatorRecord: Record "Option Designators";
    begin
        DesignatorRecord.Reset();
        DesignatorRecord.SetFilter(Designator, DesignatorText);
        if DesignatorRecord.FindFirst() then begin
            exit(DesignatorRecord);
        end else begin
            Error('Designator not found. %1 does not exist - Please select an existing option or add a new option that matches your desired selection.', DesignatorText);
        end;
    end;

    /// <summary>
    /// Creates a copy of the Option Designator with the specified designator text.
    /// </summary>
    /// <param name="DesignatorText">The designator text to use for the copy.</param>
    /// <param name="IsPrefix">If true, the designator is a prefix; otherwise, it's a suffix.</param>
    procedure CreateCopy(DesignatorText: Text[10]; IsPrefix: Boolean)
    var
        NewDesignator: Record "Option Designators";
    begin
        NewDesignator.Reset();
        if not NewDesignator.Get(DesignatorText) then begin
            NewDesignator.Init();
            NewDesignator.Designator := DesignatorText;
            if IsPrefix then begin
                NewDesignator.AtFront := true;
                NewDesignator.Order := PrefixOrder;
                NewDesignator.AssemblyID := PreAssemblyID;
            end else begin
                NewDesignator.AtFront := false;
                NewDesignator.Order := SuffixOrder;
                NewDesignator.AssemblyID := SuffixAssemblyID;
            end;
            NewDesignator.OptionID := OptionID;
            NewDesignator.Variable := false;
            NewDesignator.Id := NewDesignator.GetNewID();
            NewDesignator.Insert();
        end;
    end;

    var
        OptionRec: Record Option;
        PrefixSelection, SuffixSelection : Text[50];
}
