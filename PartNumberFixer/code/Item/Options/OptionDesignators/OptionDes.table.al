table 50112 "Option Suffix"
{
    DataClassification = ToBeClassified;

    fields
    {

        field(4; "Suffix Designator"; Text[10])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Suffix Order"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(7; Line; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(9; OptionID; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = Option.Id;
        }
        field(10; show; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(11; AssemblyChange; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Suffix Designator")
        {
            Clustered = true;
        }
        key(SK; OptionID)
        {

        }
    }
    trigger OnInsert()
    var
        oRec: Record Option;
        spl: Record SPList;
    begin
        if spl.Get(Format(OptionID) + "Suffix Designator") then begin
            if "Suffix Designator" <> '' then begin
                spl.ID := Format(OptionID) + "Suffix Designator";
                spl.Designator := "Suffix Designator";
                if oRec.get(OptionID) then begin
                    spl.Order := oRec."Suffix Order";

                end;
                spl.active := true;
                spl.prefix := false;
                spl.Modify();
            end;
        end else begin
            spl.Init();
            spl.ID := Format(OptionID) + "Suffix Designator";
            spl.Designator := "Suffix Designator";
            if oRec.get(OptionID) then begin
                spl.Order := oRec."Suffix Order";
            end;
            spl.active := true;
            spl.prefix := false;
            spl.Modify();
        end;

    end;
}
