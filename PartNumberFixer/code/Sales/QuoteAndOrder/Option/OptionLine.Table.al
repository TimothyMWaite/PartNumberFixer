table 50135 OptionLine
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; pn; Text[200])
        {
            DataClassification = ToBeClassified;

        }
        field(3; docID; code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; oID; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(5; oName; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(6; preSelection; text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(7; sufSelection; text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(8; pre; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; iID; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item."No.";
        }
        field(10; preOrder; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = Option."Prefix Order" WHERE(Id = field(oID));
        }
        field(11; sufOrder; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = Option."Suffix Order" WHERE(Id = field(oID));
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }
    // trigger OnInsert()
    // begin

    // end;

    // trigger OnModify()
    // begin

    // end;

    // trigger OnDelete()
    // begin

    // end;

    // trigger OnRename()
    // begin

    // end;

    procedure getNewID(): Integer
    begin
        if rec.FindLast() then begin
            exit(rec.ID + 1);
        end else begin
            exit(1000);
        end;
    end;

    procedure updatePN()
    var
        lRec: Record OptionLine;
    begin
        lRec.Reset();
        lRec.SetFilter(iID, rec.iID);
        lRec.SetFilter(docId, rec.docID);
        lRec.SetRange(pre, true);
        lRec.SetAscending(lRec.preOrder, true);
        if lRec.FindSet() then begin
            repeat
                if not lRec.isPreEmpty() then begin
                    p += lRec.preSelection;
                end;
            until lRec.Next() = 0;
        end;
        lRec.Reset();
        lRec.SetFilter(iID, rec.iID);
        lRec.SetFilter(docId, rec.docID);
        lRec.SetRange(pre, false);
        lRec.SetAscending(lRec.sufOrder, true);
        if lRec.FindSet() then begin
            repeat
                if not lRec.isSufEmpty() then begin
                    s += lRec.sufSelection;
                end;
            until lRec.Next() = 0;
        end;
        rec.pn := p + rec.pn + s;
        lRec.Reset();
        lRec.SetFilter(iID, rec.iID);
        lRec.SetFilter(docId, rec.docID);
        if lRec.FindSet() then begin
            repeat
                lRec.pn := rec.pn;
                lRec.Modify()
            until lRec.Next() = 0;
        end;

    end;

    procedure isPreEmpty(): Boolean
    begin
        exit(rec.preSelection = '');
    end;

    procedure isSufEmpty(): Boolean
    begin
        exit(rec.sufSelection = '');
    end;

    var
        p, s : text[50];
}
