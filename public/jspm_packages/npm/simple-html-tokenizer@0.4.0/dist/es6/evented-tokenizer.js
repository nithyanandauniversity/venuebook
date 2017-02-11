/* */ 
"format cjs";
import { preprocessInput, isAlpha, isSpace } from './utils';
function EventedTokenizer(delegate, entityParser) {
    this.delegate = delegate;
    this.entityParser = entityParser;
    this.state = null;
    this.input = null;
    this.index = -1;
    this.line = -1;
    this.column = -1;
    this.tagLine = -1;
    this.tagColumn = -1;
    this.reset();
}
EventedTokenizer.prototype = {
    reset: function () {
        this.state = 'beforeData';
        this.input = '';
        this.index = 0;
        this.line = 1;
        this.column = 0;
        this.tagLine = -1;
        this.tagColumn = -1;
        this.delegate.reset();
    },
    tokenize: function (input) {
        this.reset();
        this.tokenizePart(input);
        this.tokenizeEOF();
    },
    tokenizePart: function (input) {
        this.input += preprocessInput(input);
        while (this.index < this.input.length) {
            this.states[this.state].call(this);
        }
    },
    tokenizeEOF: function () {
        this.flushData();
    },
    flushData: function () {
        if (this.state === 'data') {
            this.delegate.finishData();
            this.state = 'beforeData';
        }
    },
    peek: function () {
        return this.input.charAt(this.index);
    },
    consume: function () {
        var char = this.peek();
        this.index++;
        if (char === "\n") {
            this.line++;
            this.column = 0;
        }
        else {
            this.column++;
        }
        return char;
    },
    consumeCharRef: function () {
        var endIndex = this.input.indexOf(';', this.index);
        if (endIndex === -1) {
            return;
        }
        var entity = this.input.slice(this.index, endIndex);
        var chars = this.entityParser.parse(entity);
        if (chars) {
            var count = entity.length;
            // consume the entity chars
            while (count) {
                this.consume();
                count--;
            }
            // consume the `;`
            this.consume();
            return chars;
        }
    },
    markTagStart: function () {
        // these properties to be removed in next major bump
        this.tagLine = this.line;
        this.tagColumn = this.column;
        if (this.delegate.tagOpen) {
            this.delegate.tagOpen();
        }
    },
    states: {
        beforeData: function () {
            var char = this.peek();
            if (char === "<") {
                this.state = 'tagOpen';
                this.markTagStart();
                this.consume();
            }
            else {
                this.state = 'data';
                this.delegate.beginData();
            }
        },
        data: function () {
            var char = this.peek();
            if (char === "<") {
                this.delegate.finishData();
                this.state = 'tagOpen';
                this.markTagStart();
                this.consume();
            }
            else if (char === "&") {
                this.consume();
                this.delegate.appendToData(this.consumeCharRef() || "&");
            }
            else {
                this.consume();
                this.delegate.appendToData(char);
            }
        },
        tagOpen: function () {
            var char = this.consume();
            if (char === "!") {
                this.state = 'markupDeclaration';
            }
            else if (char === "/") {
                this.state = 'endTagOpen';
            }
            else if (isAlpha(char)) {
                this.state = 'tagName';
                this.delegate.beginStartTag();
                this.delegate.appendToTagName(char.toLowerCase());
            }
        },
        markupDeclaration: function () {
            var char = this.consume();
            if (char === "-" && this.input.charAt(this.index) === "-") {
                this.consume();
                this.state = 'commentStart';
                this.delegate.beginComment();
            }
        },
        commentStart: function () {
            var char = this.consume();
            if (char === "-") {
                this.state = 'commentStartDash';
            }
            else if (char === ">") {
                this.delegate.finishComment();
                this.state = 'beforeData';
            }
            else {
                this.delegate.appendToCommentData(char);
                this.state = 'comment';
            }
        },
        commentStartDash: function () {
            var char = this.consume();
            if (char === "-") {
                this.state = 'commentEnd';
            }
            else if (char === ">") {
                this.delegate.finishComment();
                this.state = 'beforeData';
            }
            else {
                this.delegate.appendToCommentData("-");
                this.state = 'comment';
            }
        },
        comment: function () {
            var char = this.consume();
            if (char === "-") {
                this.state = 'commentEndDash';
            }
            else {
                this.delegate.appendToCommentData(char);
            }
        },
        commentEndDash: function () {
            var char = this.consume();
            if (char === "-") {
                this.state = 'commentEnd';
            }
            else {
                this.delegate.appendToCommentData("-" + char);
                this.state = 'comment';
            }
        },
        commentEnd: function () {
            var char = this.consume();
            if (char === ">") {
                this.delegate.finishComment();
                this.state = 'beforeData';
            }
            else {
                this.delegate.appendToCommentData("--" + char);
                this.state = 'comment';
            }
        },
        tagName: function () {
            var char = this.consume();
            if (isSpace(char)) {
                this.state = 'beforeAttributeName';
            }
            else if (char === "/") {
                this.state = 'selfClosingStartTag';
            }
            else if (char === ">") {
                this.delegate.finishTag();
                this.state = 'beforeData';
            }
            else {
                this.delegate.appendToTagName(char);
            }
        },
        beforeAttributeName: function () {
            var char = this.peek();
            if (isSpace(char)) {
                this.consume();
                return;
            }
            else if (char === "/") {
                this.state = 'selfClosingStartTag';
                this.consume();
            }
            else if (char === ">") {
                this.consume();
                this.delegate.finishTag();
                this.state = 'beforeData';
            }
            else if (char === '=') {
                this.delegate.reportSyntaxError("attribute name cannot start with equals sign");
                this.state = 'attributeName';
                this.delegate.beginAttribute();
                this.consume();
                this.delegate.appendToAttributeName(char);
            }
            else {
                this.state = 'attributeName';
                this.delegate.beginAttribute();
            }
        },
        attributeName: function () {
            var char = this.peek();
            if (isSpace(char)) {
                this.state = 'afterAttributeName';
                this.consume();
            }
            else if (char === "/") {
                this.delegate.beginAttributeValue(false);
                this.delegate.finishAttributeValue();
                this.consume();
                this.state = 'selfClosingStartTag';
            }
            else if (char === "=") {
                this.state = 'beforeAttributeValue';
                this.consume();
            }
            else if (char === ">") {
                this.delegate.beginAttributeValue(false);
                this.delegate.finishAttributeValue();
                this.consume();
                this.delegate.finishTag();
                this.state = 'beforeData';
            }
            else if (char === '"' || char === "'" || char === '<') {
                this.delegate.reportSyntaxError(char + " is not a valid character within attribute names");
                this.consume();
                this.delegate.appendToAttributeName(char);
            }
            else {
                this.consume();
                this.delegate.appendToAttributeName(char);
            }
        },
        afterAttributeName: function () {
            var char = this.peek();
            if (isSpace(char)) {
                this.consume();
                return;
            }
            else if (char === "/") {
                this.delegate.beginAttributeValue(false);
                this.delegate.finishAttributeValue();
                this.consume();
                this.state = 'selfClosingStartTag';
            }
            else if (char === "=") {
                this.consume();
                this.state = 'beforeAttributeValue';
            }
            else if (char === ">") {
                this.delegate.beginAttributeValue(false);
                this.delegate.finishAttributeValue();
                this.consume();
                this.delegate.finishTag();
                this.state = 'beforeData';
            }
            else {
                this.delegate.beginAttributeValue(false);
                this.delegate.finishAttributeValue();
                this.consume();
                this.state = 'attributeName';
                this.delegate.beginAttribute();
                this.delegate.appendToAttributeName(char);
            }
        },
        beforeAttributeValue: function () {
            var char = this.peek();
            if (isSpace(char)) {
                this.consume();
            }
            else if (char === '"') {
                this.state = 'attributeValueDoubleQuoted';
                this.delegate.beginAttributeValue(true);
                this.consume();
            }
            else if (char === "'") {
                this.state = 'attributeValueSingleQuoted';
                this.delegate.beginAttributeValue(true);
                this.consume();
            }
            else if (char === ">") {
                this.delegate.beginAttributeValue(false);
                this.delegate.finishAttributeValue();
                this.consume();
                this.delegate.finishTag();
                this.state = 'beforeData';
            }
            else {
                this.state = 'attributeValueUnquoted';
                this.delegate.beginAttributeValue(false);
                this.consume();
                this.delegate.appendToAttributeValue(char);
            }
        },
        attributeValueDoubleQuoted: function () {
            var char = this.consume();
            if (char === '"') {
                this.delegate.finishAttributeValue();
                this.state = 'afterAttributeValueQuoted';
            }
            else if (char === "&") {
                this.delegate.appendToAttributeValue(this.consumeCharRef('"') || "&");
            }
            else {
                this.delegate.appendToAttributeValue(char);
            }
        },
        attributeValueSingleQuoted: function () {
            var char = this.consume();
            if (char === "'") {
                this.delegate.finishAttributeValue();
                this.state = 'afterAttributeValueQuoted';
            }
            else if (char === "&") {
                this.delegate.appendToAttributeValue(this.consumeCharRef("'") || "&");
            }
            else {
                this.delegate.appendToAttributeValue(char);
            }
        },
        attributeValueUnquoted: function () {
            var char = this.peek();
            if (isSpace(char)) {
                this.delegate.finishAttributeValue();
                this.consume();
                this.state = 'beforeAttributeName';
            }
            else if (char === "&") {
                this.consume();
                this.delegate.appendToAttributeValue(this.consumeCharRef(">") || "&");
            }
            else if (char === ">") {
                this.delegate.finishAttributeValue();
                this.consume();
                this.delegate.finishTag();
                this.state = 'beforeData';
            }
            else {
                this.consume();
                this.delegate.appendToAttributeValue(char);
            }
        },
        afterAttributeValueQuoted: function () {
            var char = this.peek();
            if (isSpace(char)) {
                this.consume();
                this.state = 'beforeAttributeName';
            }
            else if (char === "/") {
                this.consume();
                this.state = 'selfClosingStartTag';
            }
            else if (char === ">") {
                this.consume();
                this.delegate.finishTag();
                this.state = 'beforeData';
            }
            else {
                this.state = 'beforeAttributeName';
            }
        },
        selfClosingStartTag: function () {
            var char = this.peek();
            if (char === ">") {
                this.consume();
                this.delegate.markTagAsSelfClosing();
                this.delegate.finishTag();
                this.state = 'beforeData';
            }
            else {
                this.state = 'beforeAttributeName';
            }
        },
        endTagOpen: function () {
            var char = this.consume();
            if (isAlpha(char)) {
                this.state = 'tagName';
                this.delegate.beginEndTag();
                this.delegate.appendToTagName(char.toLowerCase());
            }
        }
    }
};
export default EventedTokenizer;
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiZXZlbnRlZC10b2tlbml6ZXIuanMiLCJzb3VyY2VSb290IjoiIiwic291cmNlcyI6WyJldmVudGVkLXRva2VuaXplci50cyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiQUFBQSxPQUFPLEVBQUUsZUFBZSxFQUFFLE9BQU8sRUFBRSxPQUFPLEVBQUUsTUFBTSxTQUFTLENBQUM7QUFFNUQsMEJBQTBCLFFBQVEsRUFBRSxZQUFZO0lBQzlDLElBQUksQ0FBQyxRQUFRLEdBQUcsUUFBUSxDQUFDO0lBQ3pCLElBQUksQ0FBQyxZQUFZLEdBQUcsWUFBWSxDQUFDO0lBRWpDLElBQUksQ0FBQyxLQUFLLEdBQUcsSUFBSSxDQUFDO0lBQ2xCLElBQUksQ0FBQyxLQUFLLEdBQUcsSUFBSSxDQUFDO0lBRWxCLElBQUksQ0FBQyxLQUFLLEdBQUcsQ0FBQyxDQUFDLENBQUM7SUFDaEIsSUFBSSxDQUFDLElBQUksR0FBRyxDQUFDLENBQUMsQ0FBQztJQUNmLElBQUksQ0FBQyxNQUFNLEdBQUcsQ0FBQyxDQUFDLENBQUM7SUFDakIsSUFBSSxDQUFDLE9BQU8sR0FBRyxDQUFDLENBQUMsQ0FBQztJQUNsQixJQUFJLENBQUMsU0FBUyxHQUFHLENBQUMsQ0FBQyxDQUFDO0lBRXBCLElBQUksQ0FBQyxLQUFLLEVBQUUsQ0FBQztBQUNmLENBQUM7QUFFRCxnQkFBZ0IsQ0FBQyxTQUFTLEdBQUc7SUFDM0IsS0FBSyxFQUFFO1FBQ0wsSUFBSSxDQUFDLEtBQUssR0FBRyxZQUFZLENBQUM7UUFDMUIsSUFBSSxDQUFDLEtBQUssR0FBRyxFQUFFLENBQUM7UUFFaEIsSUFBSSxDQUFDLEtBQUssR0FBRyxDQUFDLENBQUM7UUFDZixJQUFJLENBQUMsSUFBSSxHQUFHLENBQUMsQ0FBQztRQUNkLElBQUksQ0FBQyxNQUFNLEdBQUcsQ0FBQyxDQUFDO1FBRWhCLElBQUksQ0FBQyxPQUFPLEdBQUcsQ0FBQyxDQUFDLENBQUM7UUFDbEIsSUFBSSxDQUFDLFNBQVMsR0FBRyxDQUFDLENBQUMsQ0FBQztRQUVwQixJQUFJLENBQUMsUUFBUSxDQUFDLEtBQUssRUFBRSxDQUFDO0lBQ3hCLENBQUM7SUFFRCxRQUFRLEVBQUUsVUFBUyxLQUFLO1FBQ3RCLElBQUksQ0FBQyxLQUFLLEVBQUUsQ0FBQztRQUNiLElBQUksQ0FBQyxZQUFZLENBQUMsS0FBSyxDQUFDLENBQUM7UUFDekIsSUFBSSxDQUFDLFdBQVcsRUFBRSxDQUFDO0lBQ3JCLENBQUM7SUFFRCxZQUFZLEVBQUUsVUFBUyxLQUFLO1FBQzFCLElBQUksQ0FBQyxLQUFLLElBQUksZUFBZSxDQUFDLEtBQUssQ0FBQyxDQUFDO1FBRXJDLE9BQU8sSUFBSSxDQUFDLEtBQUssR0FBRyxJQUFJLENBQUMsS0FBSyxDQUFDLE1BQU0sRUFBRSxDQUFDO1lBQ3RDLElBQUksQ0FBQyxNQUFNLENBQUMsSUFBSSxDQUFDLEtBQUssQ0FBQyxDQUFDLElBQUksQ0FBQyxJQUFJLENBQUMsQ0FBQztRQUNyQyxDQUFDO0lBQ0gsQ0FBQztJQUVELFdBQVcsRUFBRTtRQUNYLElBQUksQ0FBQyxTQUFTLEVBQUUsQ0FBQztJQUNuQixDQUFDO0lBRUQsU0FBUyxFQUFFO1FBQ1QsRUFBRSxDQUFDLENBQUMsSUFBSSxDQUFDLEtBQUssS0FBSyxNQUFNLENBQUMsQ0FBQyxDQUFDO1lBQzFCLElBQUksQ0FBQyxRQUFRLENBQUMsVUFBVSxFQUFFLENBQUM7WUFDM0IsSUFBSSxDQUFDLEtBQUssR0FBRyxZQUFZLENBQUM7UUFDNUIsQ0FBQztJQUNILENBQUM7SUFFRCxJQUFJLEVBQUU7UUFDSixNQUFNLENBQUMsSUFBSSxDQUFDLEtBQUssQ0FBQyxNQUFNLENBQUMsSUFBSSxDQUFDLEtBQUssQ0FBQyxDQUFDO0lBQ3ZDLENBQUM7SUFFRCxPQUFPLEVBQUU7UUFDUCxJQUFJLElBQUksR0FBRyxJQUFJLENBQUMsSUFBSSxFQUFFLENBQUM7UUFFdkIsSUFBSSxDQUFDLEtBQUssRUFBRSxDQUFDO1FBRWIsRUFBRSxDQUFDLENBQUMsSUFBSSxLQUFLLElBQUksQ0FBQyxDQUFDLENBQUM7WUFDbEIsSUFBSSxDQUFDLElBQUksRUFBRSxDQUFDO1lBQ1osSUFBSSxDQUFDLE1BQU0sR0FBRyxDQUFDLENBQUM7UUFDbEIsQ0FBQztRQUFDLElBQUksQ0FBQyxDQUFDO1lBQ04sSUFBSSxDQUFDLE1BQU0sRUFBRSxDQUFDO1FBQ2hCLENBQUM7UUFFRCxNQUFNLENBQUMsSUFBSSxDQUFDO0lBQ2QsQ0FBQztJQUVELGNBQWMsRUFBRTtRQUNkLElBQUksUUFBUSxHQUFHLElBQUksQ0FBQyxLQUFLLENBQUMsT0FBTyxDQUFDLEdBQUcsRUFBRSxJQUFJLENBQUMsS0FBSyxDQUFDLENBQUM7UUFDbkQsRUFBRSxDQUFDLENBQUMsUUFBUSxLQUFLLENBQUMsQ0FBQyxDQUFDLENBQUMsQ0FBQztZQUNwQixNQUFNLENBQUM7UUFDVCxDQUFDO1FBQ0QsSUFBSSxNQUFNLEdBQUcsSUFBSSxDQUFDLEtBQUssQ0FBQyxLQUFLLENBQUMsSUFBSSxDQUFDLEtBQUssRUFBRSxRQUFRLENBQUMsQ0FBQztRQUNwRCxJQUFJLEtBQUssR0FBRyxJQUFJLENBQUMsWUFBWSxDQUFDLEtBQUssQ0FBQyxNQUFNLENBQUMsQ0FBQztRQUM1QyxFQUFFLENBQUMsQ0FBQyxLQUFLLENBQUMsQ0FBQyxDQUFDO1lBQ1YsSUFBSSxLQUFLLEdBQUcsTUFBTSxDQUFDLE1BQU0sQ0FBQztZQUMxQiwyQkFBMkI7WUFDM0IsT0FBTyxLQUFLLEVBQUUsQ0FBQztnQkFDYixJQUFJLENBQUMsT0FBTyxFQUFFLENBQUM7Z0JBQ2YsS0FBSyxFQUFFLENBQUM7WUFDVixDQUFDO1lBQ0Qsa0JBQWtCO1lBQ2xCLElBQUksQ0FBQyxPQUFPLEVBQUUsQ0FBQztZQUVmLE1BQU0sQ0FBQyxLQUFLLENBQUM7UUFDZixDQUFDO0lBQ0gsQ0FBQztJQUVELFlBQVksRUFBRTtRQUNaLG9EQUFvRDtRQUNwRCxJQUFJLENBQUMsT0FBTyxHQUFHLElBQUksQ0FBQyxJQUFJLENBQUM7UUFDekIsSUFBSSxDQUFDLFNBQVMsR0FBRyxJQUFJLENBQUMsTUFBTSxDQUFDO1FBRTdCLEVBQUUsQ0FBQyxDQUFDLElBQUksQ0FBQyxRQUFRLENBQUMsT0FBTyxDQUFDLENBQUMsQ0FBQztZQUMxQixJQUFJLENBQUMsUUFBUSxDQUFDLE9BQU8sRUFBRSxDQUFDO1FBQzFCLENBQUM7SUFDSCxDQUFDO0lBRUQsTUFBTSxFQUFFO1FBQ04sVUFBVSxFQUFFO1lBQ1YsSUFBSSxJQUFJLEdBQUcsSUFBSSxDQUFDLElBQUksRUFBRSxDQUFDO1lBRXZCLEVBQUUsQ0FBQyxDQUFDLElBQUksS0FBSyxHQUFHLENBQUMsQ0FBQyxDQUFDO2dCQUNqQixJQUFJLENBQUMsS0FBSyxHQUFHLFNBQVMsQ0FBQztnQkFDdkIsSUFBSSxDQUFDLFlBQVksRUFBRSxDQUFDO2dCQUNwQixJQUFJLENBQUMsT0FBTyxFQUFFLENBQUM7WUFDakIsQ0FBQztZQUFDLElBQUksQ0FBQyxDQUFDO2dCQUNOLElBQUksQ0FBQyxLQUFLLEdBQUcsTUFBTSxDQUFDO2dCQUNwQixJQUFJLENBQUMsUUFBUSxDQUFDLFNBQVMsRUFBRSxDQUFDO1lBQzVCLENBQUM7UUFDSCxDQUFDO1FBRUQsSUFBSSxFQUFFO1lBQ0osSUFBSSxJQUFJLEdBQUcsSUFBSSxDQUFDLElBQUksRUFBRSxDQUFDO1lBRXZCLEVBQUUsQ0FBQyxDQUFDLElBQUksS0FBSyxHQUFHLENBQUMsQ0FBQyxDQUFDO2dCQUNqQixJQUFJLENBQUMsUUFBUSxDQUFDLFVBQVUsRUFBRSxDQUFDO2dCQUMzQixJQUFJLENBQUMsS0FBSyxHQUFHLFNBQVMsQ0FBQztnQkFDdkIsSUFBSSxDQUFDLFlBQVksRUFBRSxDQUFDO2dCQUNwQixJQUFJLENBQUMsT0FBTyxFQUFFLENBQUM7WUFDakIsQ0FBQztZQUFDLElBQUksQ0FBQyxFQUFFLENBQUMsQ0FBQyxJQUFJLEtBQUssR0FBRyxDQUFDLENBQUMsQ0FBQztnQkFDeEIsSUFBSSxDQUFDLE9BQU8sRUFBRSxDQUFDO2dCQUNmLElBQUksQ0FBQyxRQUFRLENBQUMsWUFBWSxDQUFDLElBQUksQ0FBQyxjQUFjLEVBQUUsSUFBSSxHQUFHLENBQUMsQ0FBQztZQUMzRCxDQUFDO1lBQUMsSUFBSSxDQUFDLENBQUM7Z0JBQ04sSUFBSSxDQUFDLE9BQU8sRUFBRSxDQUFDO2dCQUNmLElBQUksQ0FBQyxRQUFRLENBQUMsWUFBWSxDQUFDLElBQUksQ0FBQyxDQUFDO1lBQ25DLENBQUM7UUFDSCxDQUFDO1FBRUQsT0FBTyxFQUFFO1lBQ1AsSUFBSSxJQUFJLEdBQUcsSUFBSSxDQUFDLE9BQU8sRUFBRSxDQUFDO1lBRTFCLEVBQUUsQ0FBQyxDQUFDLElBQUksS0FBSyxHQUFHLENBQUMsQ0FBQyxDQUFDO2dCQUNqQixJQUFJLENBQUMsS0FBSyxHQUFHLG1CQUFtQixDQUFDO1lBQ25DLENBQUM7WUFBQyxJQUFJLENBQUMsRUFBRSxDQUFDLENBQUMsSUFBSSxLQUFLLEdBQUcsQ0FBQyxDQUFDLENBQUM7Z0JBQ3hCLElBQUksQ0FBQyxLQUFLLEdBQUcsWUFBWSxDQUFDO1lBQzVCLENBQUM7WUFBQyxJQUFJLENBQUMsRUFBRSxDQUFDLENBQUMsT0FBTyxDQUFDLElBQUksQ0FBQyxDQUFDLENBQUMsQ0FBQztnQkFDekIsSUFBSSxDQUFDLEtBQUssR0FBRyxTQUFTLENBQUM7Z0JBQ3ZCLElBQUksQ0FBQyxRQUFRLENBQUMsYUFBYSxFQUFFLENBQUM7Z0JBQzlCLElBQUksQ0FBQyxRQUFRLENBQUMsZUFBZSxDQUFDLElBQUksQ0FBQyxXQUFXLEVBQUUsQ0FBQyxDQUFDO1lBQ3BELENBQUM7UUFDSCxDQUFDO1FBRUQsaUJBQWlCLEVBQUU7WUFDakIsSUFBSSxJQUFJLEdBQUcsSUFBSSxDQUFDLE9BQU8sRUFBRSxDQUFDO1lBRTFCLEVBQUUsQ0FBQyxDQUFDLElBQUksS0FBSyxHQUFHLElBQUksSUFBSSxDQUFDLEtBQUssQ0FBQyxNQUFNLENBQUMsSUFBSSxDQUFDLEtBQUssQ0FBQyxLQUFLLEdBQUcsQ0FBQyxDQUFDLENBQUM7Z0JBQzFELElBQUksQ0FBQyxPQUFPLEVBQUUsQ0FBQztnQkFDZixJQUFJLENBQUMsS0FBSyxHQUFHLGNBQWMsQ0FBQztnQkFDNUIsSUFBSSxDQUFDLFFBQVEsQ0FBQyxZQUFZLEVBQUUsQ0FBQztZQUMvQixDQUFDO1FBQ0gsQ0FBQztRQUVELFlBQVksRUFBRTtZQUNaLElBQUksSUFBSSxHQUFHLElBQUksQ0FBQyxPQUFPLEVBQUUsQ0FBQztZQUUxQixFQUFFLENBQUMsQ0FBQyxJQUFJLEtBQUssR0FBRyxDQUFDLENBQUMsQ0FBQztnQkFDakIsSUFBSSxDQUFDLEtBQUssR0FBRyxrQkFBa0IsQ0FBQztZQUNsQyxDQUFDO1lBQUMsSUFBSSxDQUFDLEVBQUUsQ0FBQyxDQUFDLElBQUksS0FBSyxHQUFHLENBQUMsQ0FBQyxDQUFDO2dCQUN4QixJQUFJLENBQUMsUUFBUSxDQUFDLGFBQWEsRUFBRSxDQUFDO2dCQUM5QixJQUFJLENBQUMsS0FBSyxHQUFHLFlBQVksQ0FBQztZQUM1QixDQUFDO1lBQUMsSUFBSSxDQUFDLENBQUM7Z0JBQ04sSUFBSSxDQUFDLFFBQVEsQ0FBQyxtQkFBbUIsQ0FBQyxJQUFJLENBQUMsQ0FBQztnQkFDeEMsSUFBSSxDQUFDLEtBQUssR0FBRyxTQUFTLENBQUM7WUFDekIsQ0FBQztRQUNILENBQUM7UUFFRCxnQkFBZ0IsRUFBRTtZQUNoQixJQUFJLElBQUksR0FBRyxJQUFJLENBQUMsT0FBTyxFQUFFLENBQUM7WUFFMUIsRUFBRSxDQUFDLENBQUMsSUFBSSxLQUFLLEdBQUcsQ0FBQyxDQUFDLENBQUM7Z0JBQ2pCLElBQUksQ0FBQyxLQUFLLEdBQUcsWUFBWSxDQUFDO1lBQzVCLENBQUM7WUFBQyxJQUFJLENBQUMsRUFBRSxDQUFDLENBQUMsSUFBSSxLQUFLLEdBQUcsQ0FBQyxDQUFDLENBQUM7Z0JBQ3hCLElBQUksQ0FBQyxRQUFRLENBQUMsYUFBYSxFQUFFLENBQUM7Z0JBQzlCLElBQUksQ0FBQyxLQUFLLEdBQUcsWUFBWSxDQUFDO1lBQzVCLENBQUM7WUFBQyxJQUFJLENBQUMsQ0FBQztnQkFDTixJQUFJLENBQUMsUUFBUSxDQUFDLG1CQUFtQixDQUFDLEdBQUcsQ0FBQyxDQUFDO2dCQUN2QyxJQUFJLENBQUMsS0FBSyxHQUFHLFNBQVMsQ0FBQztZQUN6QixDQUFDO1FBQ0gsQ0FBQztRQUVELE9BQU8sRUFBRTtZQUNQLElBQUksSUFBSSxHQUFHLElBQUksQ0FBQyxPQUFPLEVBQUUsQ0FBQztZQUUxQixFQUFFLENBQUMsQ0FBQyxJQUFJLEtBQUssR0FBRyxDQUFDLENBQUMsQ0FBQztnQkFDakIsSUFBSSxDQUFDLEtBQUssR0FBRyxnQkFBZ0IsQ0FBQztZQUNoQyxDQUFDO1lBQUMsSUFBSSxDQUFDLENBQUM7Z0JBQ04sSUFBSSxDQUFDLFFBQVEsQ0FBQyxtQkFBbUIsQ0FBQyxJQUFJLENBQUMsQ0FBQztZQUMxQyxDQUFDO1FBQ0gsQ0FBQztRQUVELGNBQWMsRUFBRTtZQUNkLElBQUksSUFBSSxHQUFHLElBQUksQ0FBQyxPQUFPLEVBQUUsQ0FBQztZQUUxQixFQUFFLENBQUMsQ0FBQyxJQUFJLEtBQUssR0FBRyxDQUFDLENBQUMsQ0FBQztnQkFDakIsSUFBSSxDQUFDLEtBQUssR0FBRyxZQUFZLENBQUM7WUFDNUIsQ0FBQztZQUFDLElBQUksQ0FBQyxDQUFDO2dCQUNOLElBQUksQ0FBQyxRQUFRLENBQUMsbUJBQW1CLENBQUMsR0FBRyxHQUFHLElBQUksQ0FBQyxDQUFDO2dCQUM5QyxJQUFJLENBQUMsS0FBSyxHQUFHLFNBQVMsQ0FBQztZQUN6QixDQUFDO1FBQ0gsQ0FBQztRQUVELFVBQVUsRUFBRTtZQUNWLElBQUksSUFBSSxHQUFHLElBQUksQ0FBQyxPQUFPLEVBQUUsQ0FBQztZQUUxQixFQUFFLENBQUMsQ0FBQyxJQUFJLEtBQUssR0FBRyxDQUFDLENBQUMsQ0FBQztnQkFDakIsSUFBSSxDQUFDLFFBQVEsQ0FBQyxhQUFhLEVBQUUsQ0FBQztnQkFDOUIsSUFBSSxDQUFDLEtBQUssR0FBRyxZQUFZLENBQUM7WUFDNUIsQ0FBQztZQUFDLElBQUksQ0FBQyxDQUFDO2dCQUNOLElBQUksQ0FBQyxRQUFRLENBQUMsbUJBQW1CLENBQUMsSUFBSSxHQUFHLElBQUksQ0FBQyxDQUFDO2dCQUMvQyxJQUFJLENBQUMsS0FBSyxHQUFHLFNBQVMsQ0FBQztZQUN6QixDQUFDO1FBQ0gsQ0FBQztRQUVELE9BQU8sRUFBRTtZQUNQLElBQUksSUFBSSxHQUFHLElBQUksQ0FBQyxPQUFPLEVBQUUsQ0FBQztZQUUxQixFQUFFLENBQUMsQ0FBQyxPQUFPLENBQUMsSUFBSSxDQUFDLENBQUMsQ0FBQyxDQUFDO2dCQUNsQixJQUFJLENBQUMsS0FBSyxHQUFHLHFCQUFxQixDQUFDO1lBQ3JDLENBQUM7WUFBQyxJQUFJLENBQUMsRUFBRSxDQUFDLENBQUMsSUFBSSxLQUFLLEdBQUcsQ0FBQyxDQUFDLENBQUM7Z0JBQ3hCLElBQUksQ0FBQyxLQUFLLEdBQUcscUJBQXFCLENBQUM7WUFDckMsQ0FBQztZQUFDLElBQUksQ0FBQyxFQUFFLENBQUMsQ0FBQyxJQUFJLEtBQUssR0FBRyxDQUFDLENBQUMsQ0FBQztnQkFDeEIsSUFBSSxDQUFDLFFBQVEsQ0FBQyxTQUFTLEVBQUUsQ0FBQztnQkFDMUIsSUFBSSxDQUFDLEtBQUssR0FBRyxZQUFZLENBQUM7WUFDNUIsQ0FBQztZQUFDLElBQUksQ0FBQyxDQUFDO2dCQUNOLElBQUksQ0FBQyxRQUFRLENBQUMsZUFBZSxDQUFDLElBQUksQ0FBQyxDQUFDO1lBQ3RDLENBQUM7UUFDSCxDQUFDO1FBRUQsbUJBQW1CLEVBQUU7WUFDbkIsSUFBSSxJQUFJLEdBQUcsSUFBSSxDQUFDLElBQUksRUFBRSxDQUFDO1lBRXZCLEVBQUUsQ0FBQyxDQUFDLE9BQU8sQ0FBQyxJQUFJLENBQUMsQ0FBQyxDQUFDLENBQUM7Z0JBQ2xCLElBQUksQ0FBQyxPQUFPLEVBQUUsQ0FBQztnQkFDZixNQUFNLENBQUM7WUFDVCxDQUFDO1lBQUMsSUFBSSxDQUFDLEVBQUUsQ0FBQyxDQUFDLElBQUksS0FBSyxHQUFHLENBQUMsQ0FBQyxDQUFDO2dCQUN4QixJQUFJLENBQUMsS0FBSyxHQUFHLHFCQUFxQixDQUFDO2dCQUNuQyxJQUFJLENBQUMsT0FBTyxFQUFFLENBQUM7WUFDakIsQ0FBQztZQUFDLElBQUksQ0FBQyxFQUFFLENBQUMsQ0FBQyxJQUFJLEtBQUssR0FBRyxDQUFDLENBQUMsQ0FBQztnQkFDeEIsSUFBSSxDQUFDLE9BQU8sRUFBRSxDQUFDO2dCQUNmLElBQUksQ0FBQyxRQUFRLENBQUMsU0FBUyxFQUFFLENBQUM7Z0JBQzFCLElBQUksQ0FBQyxLQUFLLEdBQUcsWUFBWSxDQUFDO1lBQzVCLENBQUM7WUFBQyxJQUFJLENBQUMsRUFBRSxDQUFDLENBQUMsSUFBSSxLQUFLLEdBQUcsQ0FBQyxDQUFDLENBQUM7Z0JBQ3hCLElBQUksQ0FBQyxRQUFRLENBQUMsaUJBQWlCLENBQUMsOENBQThDLENBQUMsQ0FBQztnQkFDaEYsSUFBSSxDQUFDLEtBQUssR0FBRyxlQUFlLENBQUM7Z0JBQzdCLElBQUksQ0FBQyxRQUFRLENBQUMsY0FBYyxFQUFFLENBQUM7Z0JBQy9CLElBQUksQ0FBQyxPQUFPLEVBQUUsQ0FBQztnQkFDZixJQUFJLENBQUMsUUFBUSxDQUFDLHFCQUFxQixDQUFDLElBQUksQ0FBQyxDQUFDO1lBQzVDLENBQUM7WUFBQyxJQUFJLENBQUMsQ0FBQztnQkFDTixJQUFJLENBQUMsS0FBSyxHQUFHLGVBQWUsQ0FBQztnQkFDN0IsSUFBSSxDQUFDLFFBQVEsQ0FBQyxjQUFjLEVBQUUsQ0FBQztZQUNqQyxDQUFDO1FBQ0gsQ0FBQztRQUVELGFBQWEsRUFBRTtZQUNiLElBQUksSUFBSSxHQUFHLElBQUksQ0FBQyxJQUFJLEVBQUUsQ0FBQztZQUV2QixFQUFFLENBQUMsQ0FBQyxPQUFPLENBQUMsSUFBSSxDQUFDLENBQUMsQ0FBQyxDQUFDO2dCQUNsQixJQUFJLENBQUMsS0FBSyxHQUFHLG9CQUFvQixDQUFDO2dCQUNsQyxJQUFJLENBQUMsT0FBTyxFQUFFLENBQUM7WUFDakIsQ0FBQztZQUFDLElBQUksQ0FBQyxFQUFFLENBQUMsQ0FBQyxJQUFJLEtBQUssR0FBRyxDQUFDLENBQUMsQ0FBQztnQkFDeEIsSUFBSSxDQUFDLFFBQVEsQ0FBQyxtQkFBbUIsQ0FBQyxLQUFLLENBQUMsQ0FBQztnQkFDekMsSUFBSSxDQUFDLFFBQVEsQ0FBQyxvQkFBb0IsRUFBRSxDQUFDO2dCQUNyQyxJQUFJLENBQUMsT0FBTyxFQUFFLENBQUM7Z0JBQ2YsSUFBSSxDQUFDLEtBQUssR0FBRyxxQkFBcUIsQ0FBQztZQUNyQyxDQUFDO1lBQUMsSUFBSSxDQUFDLEVBQUUsQ0FBQyxDQUFDLElBQUksS0FBSyxHQUFHLENBQUMsQ0FBQyxDQUFDO2dCQUN4QixJQUFJLENBQUMsS0FBSyxHQUFHLHNCQUFzQixDQUFDO2dCQUNwQyxJQUFJLENBQUMsT0FBTyxFQUFFLENBQUM7WUFDakIsQ0FBQztZQUFDLElBQUksQ0FBQyxFQUFFLENBQUMsQ0FBQyxJQUFJLEtBQUssR0FBRyxDQUFDLENBQUMsQ0FBQztnQkFDeEIsSUFBSSxDQUFDLFFBQVEsQ0FBQyxtQkFBbUIsQ0FBQyxLQUFLLENBQUMsQ0FBQztnQkFDekMsSUFBSSxDQUFDLFFBQVEsQ0FBQyxvQkFBb0IsRUFBRSxDQUFDO2dCQUNyQyxJQUFJLENBQUMsT0FBTyxFQUFFLENBQUM7Z0JBQ2YsSUFBSSxDQUFDLFFBQVEsQ0FBQyxTQUFTLEVBQUUsQ0FBQztnQkFDMUIsSUFBSSxDQUFDLEtBQUssR0FBRyxZQUFZLENBQUM7WUFDNUIsQ0FBQztZQUFDLElBQUksQ0FBQyxFQUFFLENBQUMsQ0FBQyxJQUFJLEtBQUssR0FBRyxJQUFJLElBQUksS0FBSyxHQUFHLElBQUksSUFBSSxLQUFLLEdBQUcsQ0FBQyxDQUFDLENBQUM7Z0JBQ3hELElBQUksQ0FBQyxRQUFRLENBQUMsaUJBQWlCLENBQUMsSUFBSSxHQUFHLGtEQUFrRCxDQUFDLENBQUM7Z0JBQzNGLElBQUksQ0FBQyxPQUFPLEVBQUUsQ0FBQztnQkFDZixJQUFJLENBQUMsUUFBUSxDQUFDLHFCQUFxQixDQUFDLElBQUksQ0FBQyxDQUFDO1lBQzVDLENBQUM7WUFBQyxJQUFJLENBQUMsQ0FBQztnQkFDTixJQUFJLENBQUMsT0FBTyxFQUFFLENBQUM7Z0JBQ2YsSUFBSSxDQUFDLFFBQVEsQ0FBQyxxQkFBcUIsQ0FBQyxJQUFJLENBQUMsQ0FBQztZQUM1QyxDQUFDO1FBQ0gsQ0FBQztRQUVELGtCQUFrQixFQUFFO1lBQ2xCLElBQUksSUFBSSxHQUFHLElBQUksQ0FBQyxJQUFJLEVBQUUsQ0FBQztZQUV2QixFQUFFLENBQUMsQ0FBQyxPQUFPLENBQUMsSUFBSSxDQUFDLENBQUMsQ0FBQyxDQUFDO2dCQUNsQixJQUFJLENBQUMsT0FBTyxFQUFFLENBQUM7Z0JBQ2YsTUFBTSxDQUFDO1lBQ1QsQ0FBQztZQUFDLElBQUksQ0FBQyxFQUFFLENBQUMsQ0FBQyxJQUFJLEtBQUssR0FBRyxDQUFDLENBQUMsQ0FBQztnQkFDeEIsSUFBSSxDQUFDLFFBQVEsQ0FBQyxtQkFBbUIsQ0FBQyxLQUFLLENBQUMsQ0FBQztnQkFDekMsSUFBSSxDQUFDLFFBQVEsQ0FBQyxvQkFBb0IsRUFBRSxDQUFDO2dCQUNyQyxJQUFJLENBQUMsT0FBTyxFQUFFLENBQUM7Z0JBQ2YsSUFBSSxDQUFDLEtBQUssR0FBRyxxQkFBcUIsQ0FBQztZQUNyQyxDQUFDO1lBQUMsSUFBSSxDQUFDLEVBQUUsQ0FBQyxDQUFDLElBQUksS0FBSyxHQUFHLENBQUMsQ0FBQyxDQUFDO2dCQUN4QixJQUFJLENBQUMsT0FBTyxFQUFFLENBQUM7Z0JBQ2YsSUFBSSxDQUFDLEtBQUssR0FBRyxzQkFBc0IsQ0FBQztZQUN0QyxDQUFDO1lBQUMsSUFBSSxDQUFDLEVBQUUsQ0FBQyxDQUFDLElBQUksS0FBSyxHQUFHLENBQUMsQ0FBQyxDQUFDO2dCQUN4QixJQUFJLENBQUMsUUFBUSxDQUFDLG1CQUFtQixDQUFDLEtBQUssQ0FBQyxDQUFDO2dCQUN6QyxJQUFJLENBQUMsUUFBUSxDQUFDLG9CQUFvQixFQUFFLENBQUM7Z0JBQ3JDLElBQUksQ0FBQyxPQUFPLEVBQUUsQ0FBQztnQkFDZixJQUFJLENBQUMsUUFBUSxDQUFDLFNBQVMsRUFBRSxDQUFDO2dCQUMxQixJQUFJLENBQUMsS0FBSyxHQUFHLFlBQVksQ0FBQztZQUM1QixDQUFDO1lBQUMsSUFBSSxDQUFDLENBQUM7Z0JBQ04sSUFBSSxDQUFDLFFBQVEsQ0FBQyxtQkFBbUIsQ0FBQyxLQUFLLENBQUMsQ0FBQztnQkFDekMsSUFBSSxDQUFDLFFBQVEsQ0FBQyxvQkFBb0IsRUFBRSxDQUFDO2dCQUNyQyxJQUFJLENBQUMsT0FBTyxFQUFFLENBQUM7Z0JBQ2YsSUFBSSxDQUFDLEtBQUssR0FBRyxlQUFlLENBQUM7Z0JBQzdCLElBQUksQ0FBQyxRQUFRLENBQUMsY0FBYyxFQUFFLENBQUM7Z0JBQy9CLElBQUksQ0FBQyxRQUFRLENBQUMscUJBQXFCLENBQUMsSUFBSSxDQUFDLENBQUM7WUFDNUMsQ0FBQztRQUNILENBQUM7UUFFRCxvQkFBb0IsRUFBRTtZQUNwQixJQUFJLElBQUksR0FBRyxJQUFJLENBQUMsSUFBSSxFQUFFLENBQUM7WUFFdkIsRUFBRSxDQUFDLENBQUMsT0FBTyxDQUFDLElBQUksQ0FBQyxDQUFDLENBQUMsQ0FBQztnQkFDbEIsSUFBSSxDQUFDLE9BQU8sRUFBRSxDQUFDO1lBQ2pCLENBQUM7WUFBQyxJQUFJLENBQUMsRUFBRSxDQUFDLENBQUMsSUFBSSxLQUFLLEdBQUcsQ0FBQyxDQUFDLENBQUM7Z0JBQ3hCLElBQUksQ0FBQyxLQUFLLEdBQUcsNEJBQTRCLENBQUM7Z0JBQzFDLElBQUksQ0FBQyxRQUFRLENBQUMsbUJBQW1CLENBQUMsSUFBSSxDQUFDLENBQUM7Z0JBQ3hDLElBQUksQ0FBQyxPQUFPLEVBQUUsQ0FBQztZQUNqQixDQUFDO1lBQUMsSUFBSSxDQUFDLEVBQUUsQ0FBQyxDQUFDLElBQUksS0FBSyxHQUFHLENBQUMsQ0FBQyxDQUFDO2dCQUN4QixJQUFJLENBQUMsS0FBSyxHQUFHLDRCQUE0QixDQUFDO2dCQUMxQyxJQUFJLENBQUMsUUFBUSxDQUFDLG1CQUFtQixDQUFDLElBQUksQ0FBQyxDQUFDO2dCQUN4QyxJQUFJLENBQUMsT0FBTyxFQUFFLENBQUM7WUFDakIsQ0FBQztZQUFDLElBQUksQ0FBQyxFQUFFLENBQUMsQ0FBQyxJQUFJLEtBQUssR0FBRyxDQUFDLENBQUMsQ0FBQztnQkFDeEIsSUFBSSxDQUFDLFFBQVEsQ0FBQyxtQkFBbUIsQ0FBQyxLQUFLLENBQUMsQ0FBQztnQkFDekMsSUFBSSxDQUFDLFFBQVEsQ0FBQyxvQkFBb0IsRUFBRSxDQUFDO2dCQUNyQyxJQUFJLENBQUMsT0FBTyxFQUFFLENBQUM7Z0JBQ2YsSUFBSSxDQUFDLFFBQVEsQ0FBQyxTQUFTLEVBQUUsQ0FBQztnQkFDMUIsSUFBSSxDQUFDLEtBQUssR0FBRyxZQUFZLENBQUM7WUFDNUIsQ0FBQztZQUFDLElBQUksQ0FBQyxDQUFDO2dCQUNOLElBQUksQ0FBQyxLQUFLLEdBQUcsd0JBQXdCLENBQUM7Z0JBQ3RDLElBQUksQ0FBQyxRQUFRLENBQUMsbUJBQW1CLENBQUMsS0FBSyxDQUFDLENBQUM7Z0JBQ3pDLElBQUksQ0FBQyxPQUFPLEVBQUUsQ0FBQztnQkFDZixJQUFJLENBQUMsUUFBUSxDQUFDLHNCQUFzQixDQUFDLElBQUksQ0FBQyxDQUFDO1lBQzdDLENBQUM7UUFDSCxDQUFDO1FBRUQsMEJBQTBCLEVBQUU7WUFDMUIsSUFBSSxJQUFJLEdBQUcsSUFBSSxDQUFDLE9BQU8sRUFBRSxDQUFDO1lBRTFCLEVBQUUsQ0FBQyxDQUFDLElBQUksS0FBSyxHQUFHLENBQUMsQ0FBQyxDQUFDO2dCQUNqQixJQUFJLENBQUMsUUFBUSxDQUFDLG9CQUFvQixFQUFFLENBQUM7Z0JBQ3JDLElBQUksQ0FBQyxLQUFLLEdBQUcsMkJBQTJCLENBQUM7WUFDM0MsQ0FBQztZQUFDLElBQUksQ0FBQyxFQUFFLENBQUMsQ0FBQyxJQUFJLEtBQUssR0FBRyxDQUFDLENBQUMsQ0FBQztnQkFDeEIsSUFBSSxDQUFDLFFBQVEsQ0FBQyxzQkFBc0IsQ0FBQyxJQUFJLENBQUMsY0FBYyxDQUFDLEdBQUcsQ0FBQyxJQUFJLEdBQUcsQ0FBQyxDQUFDO1lBQ3hFLENBQUM7WUFBQyxJQUFJLENBQUMsQ0FBQztnQkFDTixJQUFJLENBQUMsUUFBUSxDQUFDLHNCQUFzQixDQUFDLElBQUksQ0FBQyxDQUFDO1lBQzdDLENBQUM7UUFDSCxDQUFDO1FBRUQsMEJBQTBCLEVBQUU7WUFDMUIsSUFBSSxJQUFJLEdBQUcsSUFBSSxDQUFDLE9BQU8sRUFBRSxDQUFDO1lBRTFCLEVBQUUsQ0FBQyxDQUFDLElBQUksS0FBSyxHQUFHLENBQUMsQ0FBQyxDQUFDO2dCQUNqQixJQUFJLENBQUMsUUFBUSxDQUFDLG9CQUFvQixFQUFFLENBQUM7Z0JBQ3JDLElBQUksQ0FBQyxLQUFLLEdBQUcsMkJBQTJCLENBQUM7WUFDM0MsQ0FBQztZQUFDLElBQUksQ0FBQyxFQUFFLENBQUMsQ0FBQyxJQUFJLEtBQUssR0FBRyxDQUFDLENBQUMsQ0FBQztnQkFDeEIsSUFBSSxDQUFDLFFBQVEsQ0FBQyxzQkFBc0IsQ0FBQyxJQUFJLENBQUMsY0FBYyxDQUFDLEdBQUcsQ0FBQyxJQUFJLEdBQUcsQ0FBQyxDQUFDO1lBQ3hFLENBQUM7WUFBQyxJQUFJLENBQUMsQ0FBQztnQkFDTixJQUFJLENBQUMsUUFBUSxDQUFDLHNCQUFzQixDQUFDLElBQUksQ0FBQyxDQUFDO1lBQzdDLENBQUM7UUFDSCxDQUFDO1FBRUQsc0JBQXNCLEVBQUU7WUFDdEIsSUFBSSxJQUFJLEdBQUcsSUFBSSxDQUFDLElBQUksRUFBRSxDQUFDO1lBRXZCLEVBQUUsQ0FBQyxDQUFDLE9BQU8sQ0FBQyxJQUFJLENBQUMsQ0FBQyxDQUFDLENBQUM7Z0JBQ2xCLElBQUksQ0FBQyxRQUFRLENBQUMsb0JBQW9CLEVBQUUsQ0FBQztnQkFDckMsSUFBSSxDQUFDLE9BQU8sRUFBRSxDQUFDO2dCQUNmLElBQUksQ0FBQyxLQUFLLEdBQUcscUJBQXFCLENBQUM7WUFDckMsQ0FBQztZQUFDLElBQUksQ0FBQyxFQUFFLENBQUMsQ0FBQyxJQUFJLEtBQUssR0FBRyxDQUFDLENBQUMsQ0FBQztnQkFDeEIsSUFBSSxDQUFDLE9BQU8sRUFBRSxDQUFDO2dCQUNmLElBQUksQ0FBQyxRQUFRLENBQUMsc0JBQXNCLENBQUMsSUFBSSxDQUFDLGNBQWMsQ0FBQyxHQUFHLENBQUMsSUFBSSxHQUFHLENBQUMsQ0FBQztZQUN4RSxDQUFDO1lBQUMsSUFBSSxDQUFDLEVBQUUsQ0FBQyxDQUFDLElBQUksS0FBSyxHQUFHLENBQUMsQ0FBQyxDQUFDO2dCQUN4QixJQUFJLENBQUMsUUFBUSxDQUFDLG9CQUFvQixFQUFFLENBQUM7Z0JBQ3JDLElBQUksQ0FBQyxPQUFPLEVBQUUsQ0FBQztnQkFDZixJQUFJLENBQUMsUUFBUSxDQUFDLFNBQVMsRUFBRSxDQUFDO2dCQUMxQixJQUFJLENBQUMsS0FBSyxHQUFHLFlBQVksQ0FBQztZQUM1QixDQUFDO1lBQUMsSUFBSSxDQUFDLENBQUM7Z0JBQ04sSUFBSSxDQUFDLE9BQU8sRUFBRSxDQUFDO2dCQUNmLElBQUksQ0FBQyxRQUFRLENBQUMsc0JBQXNCLENBQUMsSUFBSSxDQUFDLENBQUM7WUFDN0MsQ0FBQztRQUNILENBQUM7UUFFRCx5QkFBeUIsRUFBRTtZQUN6QixJQUFJLElBQUksR0FBRyxJQUFJLENBQUMsSUFBSSxFQUFFLENBQUM7WUFFdkIsRUFBRSxDQUFDLENBQUMsT0FBTyxDQUFDLElBQUksQ0FBQyxDQUFDLENBQUMsQ0FBQztnQkFDbEIsSUFBSSxDQUFDLE9BQU8sRUFBRSxDQUFDO2dCQUNmLElBQUksQ0FBQyxLQUFLLEdBQUcscUJBQXFCLENBQUM7WUFDckMsQ0FBQztZQUFDLElBQUksQ0FBQyxFQUFFLENBQUMsQ0FBQyxJQUFJLEtBQUssR0FBRyxDQUFDLENBQUMsQ0FBQztnQkFDeEIsSUFBSSxDQUFDLE9BQU8sRUFBRSxDQUFDO2dCQUNmLElBQUksQ0FBQyxLQUFLLEdBQUcscUJBQXFCLENBQUM7WUFDckMsQ0FBQztZQUFDLElBQUksQ0FBQyxFQUFFLENBQUMsQ0FBQyxJQUFJLEtBQUssR0FBRyxDQUFDLENBQUMsQ0FBQztnQkFDeEIsSUFBSSxDQUFDLE9BQU8sRUFBRSxDQUFDO2dCQUNmLElBQUksQ0FBQyxRQUFRLENBQUMsU0FBUyxFQUFFLENBQUM7Z0JBQzFCLElBQUksQ0FBQyxLQUFLLEdBQUcsWUFBWSxDQUFDO1lBQzVCLENBQUM7WUFBQyxJQUFJLENBQUMsQ0FBQztnQkFDTixJQUFJLENBQUMsS0FBSyxHQUFHLHFCQUFxQixDQUFDO1lBQ3JDLENBQUM7UUFDSCxDQUFDO1FBRUQsbUJBQW1CLEVBQUU7WUFDbkIsSUFBSSxJQUFJLEdBQUcsSUFBSSxDQUFDLElBQUksRUFBRSxDQUFDO1lBRXZCLEVBQUUsQ0FBQyxDQUFDLElBQUksS0FBSyxHQUFHLENBQUMsQ0FBQyxDQUFDO2dCQUNqQixJQUFJLENBQUMsT0FBTyxFQUFFLENBQUM7Z0JBQ2YsSUFBSSxDQUFDLFFBQVEsQ0FBQyxvQkFBb0IsRUFBRSxDQUFDO2dCQUNyQyxJQUFJLENBQUMsUUFBUSxDQUFDLFNBQVMsRUFBRSxDQUFDO2dCQUMxQixJQUFJLENBQUMsS0FBSyxHQUFHLFlBQVksQ0FBQztZQUM1QixDQUFDO1lBQUMsSUFBSSxDQUFDLENBQUM7Z0JBQ04sSUFBSSxDQUFDLEtBQUssR0FBRyxxQkFBcUIsQ0FBQztZQUNyQyxDQUFDO1FBQ0gsQ0FBQztRQUVELFVBQVUsRUFBRTtZQUNWLElBQUksSUFBSSxHQUFHLElBQUksQ0FBQyxPQUFPLEVBQUUsQ0FBQztZQUUxQixFQUFFLENBQUMsQ0FBQyxPQUFPLENBQUMsSUFBSSxDQUFDLENBQUMsQ0FBQyxDQUFDO2dCQUNsQixJQUFJLENBQUMsS0FBSyxHQUFHLFNBQVMsQ0FBQztnQkFDdkIsSUFBSSxDQUFDLFFBQVEsQ0FBQyxXQUFXLEVBQUUsQ0FBQztnQkFDNUIsSUFBSSxDQUFDLFFBQVEsQ0FBQyxlQUFlLENBQUMsSUFBSSxDQUFDLFdBQVcsRUFBRSxDQUFDLENBQUM7WUFDcEQsQ0FBQztRQUNILENBQUM7S0FDRjtDQUNGLENBQUM7QUFFRixlQUFlLGdCQUFnQixDQUFDIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IHsgcHJlcHJvY2Vzc0lucHV0LCBpc0FscGhhLCBpc1NwYWNlIH0gZnJvbSAnLi91dGlscyc7XG5cbmZ1bmN0aW9uIEV2ZW50ZWRUb2tlbml6ZXIoZGVsZWdhdGUsIGVudGl0eVBhcnNlcikge1xuICB0aGlzLmRlbGVnYXRlID0gZGVsZWdhdGU7XG4gIHRoaXMuZW50aXR5UGFyc2VyID0gZW50aXR5UGFyc2VyO1xuXG4gIHRoaXMuc3RhdGUgPSBudWxsO1xuICB0aGlzLmlucHV0ID0gbnVsbDtcblxuICB0aGlzLmluZGV4ID0gLTE7XG4gIHRoaXMubGluZSA9IC0xO1xuICB0aGlzLmNvbHVtbiA9IC0xO1xuICB0aGlzLnRhZ0xpbmUgPSAtMTtcbiAgdGhpcy50YWdDb2x1bW4gPSAtMTtcblxuICB0aGlzLnJlc2V0KCk7XG59XG5cbkV2ZW50ZWRUb2tlbml6ZXIucHJvdG90eXBlID0ge1xuICByZXNldDogZnVuY3Rpb24oKSB7XG4gICAgdGhpcy5zdGF0ZSA9ICdiZWZvcmVEYXRhJztcbiAgICB0aGlzLmlucHV0ID0gJyc7XG5cbiAgICB0aGlzLmluZGV4ID0gMDtcbiAgICB0aGlzLmxpbmUgPSAxO1xuICAgIHRoaXMuY29sdW1uID0gMDtcblxuICAgIHRoaXMudGFnTGluZSA9IC0xO1xuICAgIHRoaXMudGFnQ29sdW1uID0gLTE7XG5cbiAgICB0aGlzLmRlbGVnYXRlLnJlc2V0KCk7XG4gIH0sXG5cbiAgdG9rZW5pemU6IGZ1bmN0aW9uKGlucHV0KSB7XG4gICAgdGhpcy5yZXNldCgpO1xuICAgIHRoaXMudG9rZW5pemVQYXJ0KGlucHV0KTtcbiAgICB0aGlzLnRva2VuaXplRU9GKCk7XG4gIH0sXG5cbiAgdG9rZW5pemVQYXJ0OiBmdW5jdGlvbihpbnB1dCkge1xuICAgIHRoaXMuaW5wdXQgKz0gcHJlcHJvY2Vzc0lucHV0KGlucHV0KTtcblxuICAgIHdoaWxlICh0aGlzLmluZGV4IDwgdGhpcy5pbnB1dC5sZW5ndGgpIHtcbiAgICAgIHRoaXMuc3RhdGVzW3RoaXMuc3RhdGVdLmNhbGwodGhpcyk7XG4gICAgfVxuICB9LFxuXG4gIHRva2VuaXplRU9GOiBmdW5jdGlvbigpIHtcbiAgICB0aGlzLmZsdXNoRGF0YSgpO1xuICB9LFxuXG4gIGZsdXNoRGF0YTogZnVuY3Rpb24oKSB7XG4gICAgaWYgKHRoaXMuc3RhdGUgPT09ICdkYXRhJykge1xuICAgICAgdGhpcy5kZWxlZ2F0ZS5maW5pc2hEYXRhKCk7XG4gICAgICB0aGlzLnN0YXRlID0gJ2JlZm9yZURhdGEnO1xuICAgIH1cbiAgfSxcblxuICBwZWVrOiBmdW5jdGlvbigpIHtcbiAgICByZXR1cm4gdGhpcy5pbnB1dC5jaGFyQXQodGhpcy5pbmRleCk7XG4gIH0sXG5cbiAgY29uc3VtZTogZnVuY3Rpb24oKSB7XG4gICAgbGV0IGNoYXIgPSB0aGlzLnBlZWsoKTtcblxuICAgIHRoaXMuaW5kZXgrKztcblxuICAgIGlmIChjaGFyID09PSBcIlxcblwiKSB7XG4gICAgICB0aGlzLmxpbmUrKztcbiAgICAgIHRoaXMuY29sdW1uID0gMDtcbiAgICB9IGVsc2Uge1xuICAgICAgdGhpcy5jb2x1bW4rKztcbiAgICB9XG5cbiAgICByZXR1cm4gY2hhcjtcbiAgfSxcblxuICBjb25zdW1lQ2hhclJlZjogZnVuY3Rpb24oKSB7XG4gICAgbGV0IGVuZEluZGV4ID0gdGhpcy5pbnB1dC5pbmRleE9mKCc7JywgdGhpcy5pbmRleCk7XG4gICAgaWYgKGVuZEluZGV4ID09PSAtMSkge1xuICAgICAgcmV0dXJuO1xuICAgIH1cbiAgICBsZXQgZW50aXR5ID0gdGhpcy5pbnB1dC5zbGljZSh0aGlzLmluZGV4LCBlbmRJbmRleCk7XG4gICAgbGV0IGNoYXJzID0gdGhpcy5lbnRpdHlQYXJzZXIucGFyc2UoZW50aXR5KTtcbiAgICBpZiAoY2hhcnMpIHtcbiAgICAgIGxldCBjb3VudCA9IGVudGl0eS5sZW5ndGg7XG4gICAgICAvLyBjb25zdW1lIHRoZSBlbnRpdHkgY2hhcnNcbiAgICAgIHdoaWxlIChjb3VudCkge1xuICAgICAgICB0aGlzLmNvbnN1bWUoKTtcbiAgICAgICAgY291bnQtLTtcbiAgICAgIH1cbiAgICAgIC8vIGNvbnN1bWUgdGhlIGA7YFxuICAgICAgdGhpcy5jb25zdW1lKCk7XG5cbiAgICAgIHJldHVybiBjaGFycztcbiAgICB9XG4gIH0sXG5cbiAgbWFya1RhZ1N0YXJ0OiBmdW5jdGlvbigpIHtcbiAgICAvLyB0aGVzZSBwcm9wZXJ0aWVzIHRvIGJlIHJlbW92ZWQgaW4gbmV4dCBtYWpvciBidW1wXG4gICAgdGhpcy50YWdMaW5lID0gdGhpcy5saW5lO1xuICAgIHRoaXMudGFnQ29sdW1uID0gdGhpcy5jb2x1bW47XG5cbiAgICBpZiAodGhpcy5kZWxlZ2F0ZS50YWdPcGVuKSB7XG4gICAgICB0aGlzLmRlbGVnYXRlLnRhZ09wZW4oKTtcbiAgICB9XG4gIH0sXG5cbiAgc3RhdGVzOiB7XG4gICAgYmVmb3JlRGF0YTogZnVuY3Rpb24oKSB7XG4gICAgICBsZXQgY2hhciA9IHRoaXMucGVlaygpO1xuXG4gICAgICBpZiAoY2hhciA9PT0gXCI8XCIpIHtcbiAgICAgICAgdGhpcy5zdGF0ZSA9ICd0YWdPcGVuJztcbiAgICAgICAgdGhpcy5tYXJrVGFnU3RhcnQoKTtcbiAgICAgICAgdGhpcy5jb25zdW1lKCk7XG4gICAgICB9IGVsc2Uge1xuICAgICAgICB0aGlzLnN0YXRlID0gJ2RhdGEnO1xuICAgICAgICB0aGlzLmRlbGVnYXRlLmJlZ2luRGF0YSgpO1xuICAgICAgfVxuICAgIH0sXG5cbiAgICBkYXRhOiBmdW5jdGlvbigpIHtcbiAgICAgIGxldCBjaGFyID0gdGhpcy5wZWVrKCk7XG5cbiAgICAgIGlmIChjaGFyID09PSBcIjxcIikge1xuICAgICAgICB0aGlzLmRlbGVnYXRlLmZpbmlzaERhdGEoKTtcbiAgICAgICAgdGhpcy5zdGF0ZSA9ICd0YWdPcGVuJztcbiAgICAgICAgdGhpcy5tYXJrVGFnU3RhcnQoKTtcbiAgICAgICAgdGhpcy5jb25zdW1lKCk7wqBcbiAgICAgIH0gZWxzZSBpZiAoY2hhciA9PT0gXCImXCIpIHtcbiAgICAgICAgdGhpcy5jb25zdW1lKCk7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuYXBwZW5kVG9EYXRhKHRoaXMuY29uc3VtZUNoYXJSZWYoKSB8fCBcIiZcIik7XG4gICAgICB9IGVsc2Uge1xuICAgICAgICB0aGlzLmNvbnN1bWUoKTtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5hcHBlbmRUb0RhdGEoY2hhcik7XG4gICAgICB9XG4gICAgfSxcblxuICAgIHRhZ09wZW46IGZ1bmN0aW9uKCkge1xuICAgICAgbGV0IGNoYXIgPSB0aGlzLmNvbnN1bWUoKTtcblxuICAgICAgaWYgKGNoYXIgPT09IFwiIVwiKSB7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnbWFya3VwRGVjbGFyYXRpb24nO1xuICAgICAgfSBlbHNlIGlmIChjaGFyID09PSBcIi9cIikge1xuICAgICAgICB0aGlzLnN0YXRlID0gJ2VuZFRhZ09wZW4nO1xuICAgICAgfSBlbHNlIGlmIChpc0FscGhhKGNoYXIpKSB7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAndGFnTmFtZSc7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuYmVnaW5TdGFydFRhZygpO1xuICAgICAgICB0aGlzLmRlbGVnYXRlLmFwcGVuZFRvVGFnTmFtZShjaGFyLnRvTG93ZXJDYXNlKCkpO1xuICAgICAgfVxuICAgIH0sXG5cbiAgICBtYXJrdXBEZWNsYXJhdGlvbjogZnVuY3Rpb24oKSB7XG4gICAgICBsZXQgY2hhciA9IHRoaXMuY29uc3VtZSgpO1xuXG4gICAgICBpZiAoY2hhciA9PT0gXCItXCIgJiYgdGhpcy5pbnB1dC5jaGFyQXQodGhpcy5pbmRleCkgPT09IFwiLVwiKSB7XG4gICAgICAgIHRoaXMuY29uc3VtZSgpO1xuICAgICAgICB0aGlzLnN0YXRlID0gJ2NvbW1lbnRTdGFydCc7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuYmVnaW5Db21tZW50KCk7XG4gICAgICB9XG4gICAgfSxcblxuICAgIGNvbW1lbnRTdGFydDogZnVuY3Rpb24oKSB7XG4gICAgICBsZXQgY2hhciA9IHRoaXMuY29uc3VtZSgpO1xuXG4gICAgICBpZiAoY2hhciA9PT0gXCItXCIpIHtcbiAgICAgICAgdGhpcy5zdGF0ZSA9ICdjb21tZW50U3RhcnREYXNoJztcbiAgICAgIH0gZWxzZSBpZiAoY2hhciA9PT0gXCI+XCIpIHtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5maW5pc2hDb21tZW50KCk7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnYmVmb3JlRGF0YSc7XG4gICAgICB9IGVsc2Uge1xuICAgICAgICB0aGlzLmRlbGVnYXRlLmFwcGVuZFRvQ29tbWVudERhdGEoY2hhcik7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnY29tbWVudCc7XG4gICAgICB9XG4gICAgfSxcblxuICAgIGNvbW1lbnRTdGFydERhc2g6IGZ1bmN0aW9uKCkge1xuICAgICAgbGV0IGNoYXIgPSB0aGlzLmNvbnN1bWUoKTtcblxuICAgICAgaWYgKGNoYXIgPT09IFwiLVwiKSB7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnY29tbWVudEVuZCc7XG4gICAgICB9IGVsc2UgaWYgKGNoYXIgPT09IFwiPlwiKSB7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuZmluaXNoQ29tbWVudCgpO1xuICAgICAgICB0aGlzLnN0YXRlID0gJ2JlZm9yZURhdGEnO1xuICAgICAgfSBlbHNlIHtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5hcHBlbmRUb0NvbW1lbnREYXRhKFwiLVwiKTtcbiAgICAgICAgdGhpcy5zdGF0ZSA9ICdjb21tZW50JztcbiAgICAgIH1cbiAgICB9LFxuXG4gICAgY29tbWVudDogZnVuY3Rpb24oKSB7XG4gICAgICBsZXQgY2hhciA9IHRoaXMuY29uc3VtZSgpO1xuXG4gICAgICBpZiAoY2hhciA9PT0gXCItXCIpIHtcbiAgICAgICAgdGhpcy5zdGF0ZSA9ICdjb21tZW50RW5kRGFzaCc7XG4gICAgICB9IGVsc2Uge1xuICAgICAgICB0aGlzLmRlbGVnYXRlLmFwcGVuZFRvQ29tbWVudERhdGEoY2hhcik7XG4gICAgICB9XG4gICAgfSxcblxuICAgIGNvbW1lbnRFbmREYXNoOiBmdW5jdGlvbigpIHtcbiAgICAgIGxldCBjaGFyID0gdGhpcy5jb25zdW1lKCk7XG5cbiAgICAgIGlmIChjaGFyID09PSBcIi1cIikge1xuICAgICAgICB0aGlzLnN0YXRlID0gJ2NvbW1lbnRFbmQnO1xuICAgICAgfSBlbHNlIHtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5hcHBlbmRUb0NvbW1lbnREYXRhKFwiLVwiICsgY2hhcik7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnY29tbWVudCc7XG4gICAgICB9XG4gICAgfSxcblxuICAgIGNvbW1lbnRFbmQ6IGZ1bmN0aW9uKCkge1xuICAgICAgbGV0IGNoYXIgPSB0aGlzLmNvbnN1bWUoKTtcblxuICAgICAgaWYgKGNoYXIgPT09IFwiPlwiKSB7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuZmluaXNoQ29tbWVudCgpO1xuICAgICAgICB0aGlzLnN0YXRlID0gJ2JlZm9yZURhdGEnO1xuICAgICAgfSBlbHNlIHtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5hcHBlbmRUb0NvbW1lbnREYXRhKFwiLS1cIiArIGNoYXIpO1xuICAgICAgICB0aGlzLnN0YXRlID0gJ2NvbW1lbnQnO1xuICAgICAgfVxuICAgIH0sXG5cbiAgICB0YWdOYW1lOiBmdW5jdGlvbigpIHtcbiAgICAgIGxldCBjaGFyID0gdGhpcy5jb25zdW1lKCk7XG5cbiAgICAgIGlmIChpc1NwYWNlKGNoYXIpKSB7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnYmVmb3JlQXR0cmlidXRlTmFtZSc7XG4gICAgICB9IGVsc2UgaWYgKGNoYXIgPT09IFwiL1wiKSB7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnc2VsZkNsb3NpbmdTdGFydFRhZyc7XG4gICAgICB9IGVsc2UgaWYgKGNoYXIgPT09IFwiPlwiKSB7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuZmluaXNoVGFnKCk7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnYmVmb3JlRGF0YSc7XG4gICAgICB9IGVsc2Uge1xuICAgICAgICB0aGlzLmRlbGVnYXRlLmFwcGVuZFRvVGFnTmFtZShjaGFyKTtcbiAgICAgIH1cbiAgICB9LFxuXG4gICAgYmVmb3JlQXR0cmlidXRlTmFtZTogZnVuY3Rpb24oKSB7XG4gICAgICBsZXQgY2hhciA9IHRoaXMucGVlaygpO1xuXG4gICAgICBpZiAoaXNTcGFjZShjaGFyKSkge1xuICAgICAgICB0aGlzLmNvbnN1bWUoKTtcbiAgICAgICAgcmV0dXJuO1xuICAgICAgfSBlbHNlIGlmIChjaGFyID09PSBcIi9cIikge1xuICAgICAgICB0aGlzLnN0YXRlID0gJ3NlbGZDbG9zaW5nU3RhcnRUYWcnO1xuICAgICAgICB0aGlzLmNvbnN1bWUoKTtcbiAgICAgIH0gZWxzZSBpZiAoY2hhciA9PT0gXCI+XCIpIHtcbiAgICAgICAgdGhpcy5jb25zdW1lKCk7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuZmluaXNoVGFnKCk7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnYmVmb3JlRGF0YSc7XG4gICAgICB9IGVsc2UgaWYgKGNoYXIgPT09ICc9Jykge1xuICAgICAgICB0aGlzLmRlbGVnYXRlLnJlcG9ydFN5bnRheEVycm9yKFwiYXR0cmlidXRlIG5hbWUgY2Fubm90IHN0YXJ0IHdpdGggZXF1YWxzIHNpZ25cIik7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnYXR0cmlidXRlTmFtZSc7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuYmVnaW5BdHRyaWJ1dGUoKTtcbiAgICAgICAgdGhpcy5jb25zdW1lKCk7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuYXBwZW5kVG9BdHRyaWJ1dGVOYW1lKGNoYXIpO1xuICAgICAgfSBlbHNlIHtcbiAgICAgICAgdGhpcy5zdGF0ZSA9ICdhdHRyaWJ1dGVOYW1lJztcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5iZWdpbkF0dHJpYnV0ZSgpO1xuICAgICAgfVxuICAgIH0sXG5cbiAgICBhdHRyaWJ1dGVOYW1lOiBmdW5jdGlvbigpIHtcbiAgICAgIGxldCBjaGFyID0gdGhpcy5wZWVrKCk7XG5cbiAgICAgIGlmIChpc1NwYWNlKGNoYXIpKSB7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnYWZ0ZXJBdHRyaWJ1dGVOYW1lJztcbiAgICAgICAgdGhpcy5jb25zdW1lKCk7XG4gICAgICB9IGVsc2UgaWYgKGNoYXIgPT09IFwiL1wiKSB7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuYmVnaW5BdHRyaWJ1dGVWYWx1ZShmYWxzZSk7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuZmluaXNoQXR0cmlidXRlVmFsdWUoKTtcbiAgICAgICAgdGhpcy5jb25zdW1lKCk7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnc2VsZkNsb3NpbmdTdGFydFRhZyc7XG4gICAgICB9IGVsc2UgaWYgKGNoYXIgPT09IFwiPVwiKSB7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnYmVmb3JlQXR0cmlidXRlVmFsdWUnO1xuICAgICAgICB0aGlzLmNvbnN1bWUoKTtcbiAgICAgIH0gZWxzZSBpZiAoY2hhciA9PT0gXCI+XCIpIHtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5iZWdpbkF0dHJpYnV0ZVZhbHVlKGZhbHNlKTtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5maW5pc2hBdHRyaWJ1dGVWYWx1ZSgpO1xuICAgICAgICB0aGlzLmNvbnN1bWUoKTtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5maW5pc2hUYWcoKTtcbiAgICAgICAgdGhpcy5zdGF0ZSA9ICdiZWZvcmVEYXRhJztcbiAgICAgIH0gZWxzZSBpZiAoY2hhciA9PT0gJ1wiJyB8fCBjaGFyID09PSBcIidcIiB8fCBjaGFyID09PSAnPCcpIHtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5yZXBvcnRTeW50YXhFcnJvcihjaGFyICsgXCIgaXMgbm90IGEgdmFsaWQgY2hhcmFjdGVyIHdpdGhpbiBhdHRyaWJ1dGUgbmFtZXNcIik7XG4gICAgICAgIHRoaXMuY29uc3VtZSgpO1xuICAgICAgICB0aGlzLmRlbGVnYXRlLmFwcGVuZFRvQXR0cmlidXRlTmFtZShjaGFyKTtcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIHRoaXMuY29uc3VtZSgpO1xuICAgICAgICB0aGlzLmRlbGVnYXRlLmFwcGVuZFRvQXR0cmlidXRlTmFtZShjaGFyKTtcbiAgICAgIH1cbiAgICB9LFxuXG4gICAgYWZ0ZXJBdHRyaWJ1dGVOYW1lOiBmdW5jdGlvbigpIHtcbiAgICAgIGxldCBjaGFyID0gdGhpcy5wZWVrKCk7XG5cbiAgICAgIGlmIChpc1NwYWNlKGNoYXIpKSB7XG4gICAgICAgIHRoaXMuY29uc3VtZSgpO1xuICAgICAgICByZXR1cm47XG4gICAgICB9IGVsc2UgaWYgKGNoYXIgPT09IFwiL1wiKSB7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuYmVnaW5BdHRyaWJ1dGVWYWx1ZShmYWxzZSk7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuZmluaXNoQXR0cmlidXRlVmFsdWUoKTtcbiAgICAgICAgdGhpcy5jb25zdW1lKCk7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnc2VsZkNsb3NpbmdTdGFydFRhZyc7XG4gICAgICB9IGVsc2UgaWYgKGNoYXIgPT09IFwiPVwiKSB7XG4gICAgICAgIHRoaXMuY29uc3VtZSgpO1xuICAgICAgICB0aGlzLnN0YXRlID0gJ2JlZm9yZUF0dHJpYnV0ZVZhbHVlJztcbiAgICAgIH0gZWxzZSBpZiAoY2hhciA9PT0gXCI+XCIpIHtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5iZWdpbkF0dHJpYnV0ZVZhbHVlKGZhbHNlKTtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5maW5pc2hBdHRyaWJ1dGVWYWx1ZSgpO1xuICAgICAgICB0aGlzLmNvbnN1bWUoKTtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5maW5pc2hUYWcoKTtcbiAgICAgICAgdGhpcy5zdGF0ZSA9ICdiZWZvcmVEYXRhJztcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuYmVnaW5BdHRyaWJ1dGVWYWx1ZShmYWxzZSk7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuZmluaXNoQXR0cmlidXRlVmFsdWUoKTtcbiAgICAgICAgdGhpcy5jb25zdW1lKCk7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnYXR0cmlidXRlTmFtZSc7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuYmVnaW5BdHRyaWJ1dGUoKTtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5hcHBlbmRUb0F0dHJpYnV0ZU5hbWUoY2hhcik7XG4gICAgICB9XG4gICAgfSxcblxuICAgIGJlZm9yZUF0dHJpYnV0ZVZhbHVlOiBmdW5jdGlvbigpIHtcbiAgICAgIGxldCBjaGFyID0gdGhpcy5wZWVrKCk7XG5cbiAgICAgIGlmIChpc1NwYWNlKGNoYXIpKSB7XG4gICAgICAgIHRoaXMuY29uc3VtZSgpO1xuICAgICAgfSBlbHNlIGlmIChjaGFyID09PSAnXCInKSB7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnYXR0cmlidXRlVmFsdWVEb3VibGVRdW90ZWQnO1xuICAgICAgICB0aGlzLmRlbGVnYXRlLmJlZ2luQXR0cmlidXRlVmFsdWUodHJ1ZSk7XG4gICAgICAgIHRoaXMuY29uc3VtZSgpO1xuICAgICAgfSBlbHNlIGlmIChjaGFyID09PSBcIidcIikge1xuICAgICAgICB0aGlzLnN0YXRlID0gJ2F0dHJpYnV0ZVZhbHVlU2luZ2xlUXVvdGVkJztcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5iZWdpbkF0dHJpYnV0ZVZhbHVlKHRydWUpO1xuICAgICAgICB0aGlzLmNvbnN1bWUoKTtcbiAgICAgIH0gZWxzZSBpZiAoY2hhciA9PT0gXCI+XCIpIHtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5iZWdpbkF0dHJpYnV0ZVZhbHVlKGZhbHNlKTtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5maW5pc2hBdHRyaWJ1dGVWYWx1ZSgpO1xuICAgICAgICB0aGlzLmNvbnN1bWUoKTtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5maW5pc2hUYWcoKTtcbiAgICAgICAgdGhpcy5zdGF0ZSA9ICdiZWZvcmVEYXRhJztcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnYXR0cmlidXRlVmFsdWVVbnF1b3RlZCc7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuYmVnaW5BdHRyaWJ1dGVWYWx1ZShmYWxzZSk7XG4gICAgICAgIHRoaXMuY29uc3VtZSgpO1xuICAgICAgICB0aGlzLmRlbGVnYXRlLmFwcGVuZFRvQXR0cmlidXRlVmFsdWUoY2hhcik7XG4gICAgICB9XG4gICAgfSxcblxuICAgIGF0dHJpYnV0ZVZhbHVlRG91YmxlUXVvdGVkOiBmdW5jdGlvbigpIHtcbiAgICAgIGxldCBjaGFyID0gdGhpcy5jb25zdW1lKCk7XG5cbiAgICAgIGlmIChjaGFyID09PSAnXCInKSB7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuZmluaXNoQXR0cmlidXRlVmFsdWUoKTtcbiAgICAgICAgdGhpcy5zdGF0ZSA9ICdhZnRlckF0dHJpYnV0ZVZhbHVlUXVvdGVkJztcbiAgICAgIH0gZWxzZSBpZiAoY2hhciA9PT0gXCImXCIpIHtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5hcHBlbmRUb0F0dHJpYnV0ZVZhbHVlKHRoaXMuY29uc3VtZUNoYXJSZWYoJ1wiJykgfHwgXCImXCIpO1xuICAgICAgfSBlbHNlIHtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5hcHBlbmRUb0F0dHJpYnV0ZVZhbHVlKGNoYXIpO1xuICAgICAgfVxuICAgIH0sXG5cbiAgICBhdHRyaWJ1dGVWYWx1ZVNpbmdsZVF1b3RlZDogZnVuY3Rpb24oKSB7XG4gICAgICBsZXQgY2hhciA9IHRoaXMuY29uc3VtZSgpO1xuXG4gICAgICBpZiAoY2hhciA9PT0gXCInXCIpIHtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5maW5pc2hBdHRyaWJ1dGVWYWx1ZSgpO1xuICAgICAgICB0aGlzLnN0YXRlID0gJ2FmdGVyQXR0cmlidXRlVmFsdWVRdW90ZWQnO1xuICAgICAgfSBlbHNlIGlmIChjaGFyID09PSBcIiZcIikge1xuICAgICAgICB0aGlzLmRlbGVnYXRlLmFwcGVuZFRvQXR0cmlidXRlVmFsdWUodGhpcy5jb25zdW1lQ2hhclJlZihcIidcIikgfHwgXCImXCIpO1xuICAgICAgfSBlbHNlIHtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5hcHBlbmRUb0F0dHJpYnV0ZVZhbHVlKGNoYXIpO1xuICAgICAgfVxuICAgIH0sXG5cbiAgICBhdHRyaWJ1dGVWYWx1ZVVucXVvdGVkOiBmdW5jdGlvbigpIHtcbiAgICAgIGxldCBjaGFyID0gdGhpcy5wZWVrKCk7XG5cbiAgICAgIGlmIChpc1NwYWNlKGNoYXIpKSB7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuZmluaXNoQXR0cmlidXRlVmFsdWUoKTtcbiAgICAgICAgdGhpcy5jb25zdW1lKCk7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnYmVmb3JlQXR0cmlidXRlTmFtZSc7XG4gICAgICB9IGVsc2UgaWYgKGNoYXIgPT09IFwiJlwiKSB7XG4gICAgICAgIHRoaXMuY29uc3VtZSgpO1xuICAgICAgICB0aGlzLmRlbGVnYXRlLmFwcGVuZFRvQXR0cmlidXRlVmFsdWUodGhpcy5jb25zdW1lQ2hhclJlZihcIj5cIikgfHwgXCImXCIpO1xuICAgICAgfSBlbHNlIGlmIChjaGFyID09PSBcIj5cIikge1xuICAgICAgICB0aGlzLmRlbGVnYXRlLmZpbmlzaEF0dHJpYnV0ZVZhbHVlKCk7XG4gICAgICAgIHRoaXMuY29uc3VtZSgpO1xuICAgICAgICB0aGlzLmRlbGVnYXRlLmZpbmlzaFRhZygpO1xuICAgICAgICB0aGlzLnN0YXRlID0gJ2JlZm9yZURhdGEnO1xuICAgICAgfSBlbHNlIHtcbiAgICAgICAgdGhpcy5jb25zdW1lKCk7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUuYXBwZW5kVG9BdHRyaWJ1dGVWYWx1ZShjaGFyKTtcbiAgICAgIH1cbiAgICB9LFxuXG4gICAgYWZ0ZXJBdHRyaWJ1dGVWYWx1ZVF1b3RlZDogZnVuY3Rpb24oKSB7XG4gICAgICBsZXQgY2hhciA9IHRoaXMucGVlaygpO1xuXG4gICAgICBpZiAoaXNTcGFjZShjaGFyKSkge1xuICAgICAgICB0aGlzLmNvbnN1bWUoKTtcbiAgICAgICAgdGhpcy5zdGF0ZSA9ICdiZWZvcmVBdHRyaWJ1dGVOYW1lJztcbiAgICAgIH0gZWxzZSBpZiAoY2hhciA9PT0gXCIvXCIpIHtcbiAgICAgICAgdGhpcy5jb25zdW1lKCk7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnc2VsZkNsb3NpbmdTdGFydFRhZyc7XG4gICAgICB9IGVsc2UgaWYgKGNoYXIgPT09IFwiPlwiKSB7XG4gICAgICAgIHRoaXMuY29uc3VtZSgpO1xuICAgICAgICB0aGlzLmRlbGVnYXRlLmZpbmlzaFRhZygpO1xuICAgICAgICB0aGlzLnN0YXRlID0gJ2JlZm9yZURhdGEnO1xuICAgICAgfSBlbHNlIHtcbiAgICAgICAgdGhpcy5zdGF0ZSA9ICdiZWZvcmVBdHRyaWJ1dGVOYW1lJztcbiAgICAgIH1cbiAgICB9LFxuXG4gICAgc2VsZkNsb3NpbmdTdGFydFRhZzogZnVuY3Rpb24oKSB7XG4gICAgICBsZXQgY2hhciA9IHRoaXMucGVlaygpO1xuXG4gICAgICBpZiAoY2hhciA9PT0gXCI+XCIpIHtcbiAgICAgICAgdGhpcy5jb25zdW1lKCk7XG4gICAgICAgIHRoaXMuZGVsZWdhdGUubWFya1RhZ0FzU2VsZkNsb3NpbmcoKTtcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5maW5pc2hUYWcoKTtcbiAgICAgICAgdGhpcy5zdGF0ZSA9ICdiZWZvcmVEYXRhJztcbiAgICAgIH0gZWxzZSB7XG4gICAgICAgIHRoaXMuc3RhdGUgPSAnYmVmb3JlQXR0cmlidXRlTmFtZSc7XG4gICAgICB9XG4gICAgfSxcblxuICAgIGVuZFRhZ09wZW46IGZ1bmN0aW9uKCkge1xuICAgICAgbGV0IGNoYXIgPSB0aGlzLmNvbnN1bWUoKTtcblxuICAgICAgaWYgKGlzQWxwaGEoY2hhcikpIHtcbiAgICAgICAgdGhpcy5zdGF0ZSA9ICd0YWdOYW1lJztcbiAgICAgICAgdGhpcy5kZWxlZ2F0ZS5iZWdpbkVuZFRhZygpO1xuICAgICAgICB0aGlzLmRlbGVnYXRlLmFwcGVuZFRvVGFnTmFtZShjaGFyLnRvTG93ZXJDYXNlKCkpO1xuICAgICAgfVxuICAgIH1cbiAgfVxufTtcblxuZXhwb3J0IGRlZmF1bHQgRXZlbnRlZFRva2VuaXplcjtcbiJdfQ==