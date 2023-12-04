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
        opPage.SetSelectionFilter(lRec);
        if ioRec.FindSet() then begin
            repeat
                opPage.setRecs(ioRec, i);


            until ioRec.Next() = 0;
        end;
        opPage.setSH(s);
        opPage.setI(i);
        Commit();
        if opPage.RunModal() = Action::OK then begin
            Clear(opPage);
            exit(opPage.getPN())
        end;
    end;

    var
        opPage: Page OptionLineList;

}