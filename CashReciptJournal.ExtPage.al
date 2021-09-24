/// <summary>
/// D36010.00.00 20212603 UA[#395]: Created new page extension to add action to sync order to P3PL
/// </summary>
pageextension 50102 "Cash Receipt Journal D360" extends "Cash Receipt Journal"
{


    actions
    {
        addafter("&Line")
        {
            action("Suggest Customer Refund")
            {
                ApplicationArea = all;
                Caption = 'Suggest Customer Refund';
                Image = Approval;
                Promoted = true;
                ToolTip = 'Use this action to refund the amount.';
                trigger OnAction();


                begin

                    Report.RUN(Report::"SuggestCustPayment");

                end;
            }



        }


    }
}