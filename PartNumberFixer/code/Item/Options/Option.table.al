table 50106 "Option"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                oRec: Record Option;
            begin
                // if Id = 0 then begin
                //     if oRec.FindLast() then begin
                //         Id := oRec.Id + 1;
                //     end;
                // end;
            end;
        }
        field(14; Name; Text[100])
        {
            NotBlank = true;
            DataClassification = ToBeClassified;
        }
        field(15; Description; Text[500])
        {
            NotBlank = true;
            DataClassification = ToBeClassified;
        }
        field(2; Caption; Text[50])
        {
            NotBlank = true;
            DataClassification = ToBeClassified;
        }

        field(3; Required; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(7; "Price Change"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(8; AssemblyId; Integer)
        {
            DataClassification = ToBeClassified;

        }

        field(100; "Prefix Designator"; Text[10])
        {
            DataClassification = ToBeClassified;
        }
        field(101; "Prefix Order"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(102; "Suffix Order"; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Id", Name)
        {
            Clustered = true;
        }

    }
    trigger OnModify()
    var

    begin

        addToSPL();
    end;

    procedure addToSPL()
    var
        oRec: Record Option;
        spl: Record SPList;
    begin
        spl.Reset();
        spl.SetFilter(OptionID, Format(rec.Id));
        spl.SetRange(Designator, "Prefix Designator");
        if spl.FindFirst() then begin
            if "Prefix Designator" <> '' then begin
                // spl.ID := spl.getNewID();
                spl.Designator := "Prefix Designator";
                spl.Order := "Prefix Order";
                spl.active := true;
                spl.prefix := true;
                spl.Modify();
            end;
        end else begin
            if "Prefix Designator" <> '' then begin
                spl.Init();
                spl.ID := spl.getNewID();
                spl.Designator := "Prefix Designator";
                spl.Order := "Prefix Order";
                spl.active := true;
                spl.prefix := true;
                if spl.Insert(true) then begin
                    Message('ADDED PREFIX');

                end;
            end;
        end;
    end;

    procedure getNewId(): Integer
    var
        o: Record Option;
    begin
        if Id = 0 then begin
            if o.FindLast() then begin
                exit(o.Id + 1);
            end else begin
                exit(1000);
            end;
        end;
    end;

}