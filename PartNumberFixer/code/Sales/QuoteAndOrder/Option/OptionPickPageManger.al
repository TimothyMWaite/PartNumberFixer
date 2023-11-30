codeunit 50104 "OP Page Manager"
{


    procedure openPickPage(s: Record "Sales Order Entity Buffer"; i: Record "Sales Line"): Text[100]
    var
        lRec: Record OptionLine;
        sRec: Record SPList;
        ioRec: Record "Item Option Line";
    begin
        ioRec.Reset();
        ioRec.SetFilter("ItemNo.", i."No.");
        if ioRec.FindSet() then begin
            repeat
                lRec.Init();
                lRec.Id := lRec.getNewID();
                lRec.docID := i."Document No.";
                lRec.oID := ioRec.OptionID;
                lRec.iID := i."No.";
                if lRec.Insert() then begin
                    opPage.SetSelectionFilter(lRec);
                end;

            until ioRec.Next() = 0;
        end;
        opPage.setSH(s);
        opPage.setI(i);
        Commit();
        if opPage.RunModal() = Action::OK then begin
            exit(opPage.getPN())
        end;
    end;

    var
        opPage: Page OptionLineList;

}