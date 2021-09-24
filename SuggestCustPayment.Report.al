report 50111 SuggestCustPayment
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = SORTING(Blocked) WHERE(Blocked = FILTER(= " "));

            RequestFilterFields = "No.", "Payment Method Code";
            trigger OnAfterGetRecord()
            begin

                GetCustLedgEntries(TRUE, FALSE);
            End;

        }
    }


    var


        CustLedgEntry: Record "Cust. Ledger Entry";

        GenJnlLine: Record "Gen. Journal Line";
        GenJnlLine2: Record "Gen. Journal Line";
        LastLineNo: Integer;

        GenJnlLineInserted: Boolean;

    LOCAL procedure GetCustLedgEntries(Positive: Boolean; Future: Boolean)
    var

    begin
        Clear(CustLedgEntry);
        CustLedgEntry.Get(2847);
        CustLedgEntry.SETCURRENTKEY("Customer No.", Open, "Document Type");
        CustLedgEntry.SetRange("Customer No.", Customer."No.");
        CustLedgEntry.SetRange(Open, false);
        CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Payment);


        if CustLedgEntry.FindSet() then
            repeat
                CLEAR(GenJnlLine);
                GenJnlLine.SetCurrentKey("Journal Template Name", "Journal Batch Name");
                GenJnlLine.SETFILTER("Journal Template Name", 'CASHRCPT');
                GenJnlLine.SETFILTER("Journal Batch Name", 'BANK');

                IF GenJnlLine.FindLast() then
                    LastLineNo := GenJnlLine."Line No." + 10000
                else
                    LastLineNo := 10000;
            until CustLedgEntry.Next() = 0;
        InsertGenJournalLine;


    End;


    local procedure InsertGenJournalLine()
    var

    begin
        with GenJnlLine do begin
            Init;
            //Window2.Update(1, Customer."No.");//pick from customer not from buffer
            GenJnlLine."Journal Template Name" := 'CASHRCPT';
            GenJnlLine."Journal Batch Name" := 'BANK';
            GenJnlLine."Posting Date" := CustLedgEntry."Posting Date";
            GenJnlLine."Bal. Account Type" := CustLedgEntry."Bal. Account Type"::"Bank Account";
            LastLineNo := LastLineNo + 10000;
            "Line No." := LastLineNo;
            GenJnlLine."Line No." := GenJnlLine."Line No." + 10000;
            GenJnlLine."Document Type" := CustLedgEntry."Document Type"::Payment;
            GenJnlLine."Document No." := CustLedgEntry."Document No.";
            GenJnlLine."Account Type" := CustLedgEntry."Bal. Account Type"::Customer;
            GenJnlLine.Description := CustLedgEntry.Description;
            GenJnlLine."Account No." := CustLedgEntry."Customer No.";
            GenJnlLine."Bal. Account No." := CustLedgEntry."Bal. Account No.";
            CustLedgEntry.CalcFields(Amount);
            GenJnlLine.Amount := CustLedgEntry.Amount;
            CustLedgEntry.CalcFields("Amount (LCY)");
            GenJnlLine."Amount (LCY)" := "Amount (LCY)";

            Insert;
            GenJnlLineInserted := true;
        end;
    end;
}