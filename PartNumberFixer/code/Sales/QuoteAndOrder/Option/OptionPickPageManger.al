codeunit 50104 "OP Page Manager"
{


    procedure openPickPage(s: Record "Sales Order Entity Buffer"; i: Record "Sales Line"): Text[100]
    var
    begin
        opPage.setSH(s);
        opPage.setI(i);
        if opPage.RunModal() = Action::OK then begin
            exit(opPage.getPN())
        end;
    end;

    var
        opPage: Page OptionLineList;

}