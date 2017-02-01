/* */ 
"format cjs";
import Tokenizer from './tokenizer';
import EntityParser from './entity-parser';
import namedCharRefs from './html5-named-char-refs';
export default function tokenize(input, options) {
    var tokenizer = new Tokenizer(new EntityParser(namedCharRefs), options);
    return tokenizer.tokenize(input);
}
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoidG9rZW5pemUuanMiLCJzb3VyY2VSb290IjoiIiwic291cmNlcyI6WyJ0b2tlbml6ZS50cyJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiQUFBQSxPQUFPLFNBQVMsTUFBTSxhQUFhLENBQUM7QUFDcEMsT0FBTyxZQUFZLE1BQU0saUJBQWlCLENBQUM7QUFDM0MsT0FBTyxhQUFhLE1BQU0seUJBQXlCLENBQUM7QUFFcEQsTUFBTSxDQUFDLE9BQU8sbUJBQW1CLEtBQUssRUFBRSxPQUFPO0lBQzdDLElBQUksU0FBUyxHQUFHLElBQUksU0FBUyxDQUFDLElBQUksWUFBWSxDQUFDLGFBQWEsQ0FBQyxFQUFFLE9BQU8sQ0FBQyxDQUFDO0lBQ3hFLE1BQU0sQ0FBQyxTQUFTLENBQUMsUUFBUSxDQUFDLEtBQUssQ0FBQyxDQUFDO0FBQ25DLENBQUMiLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgVG9rZW5pemVyIGZyb20gJy4vdG9rZW5pemVyJztcbmltcG9ydCBFbnRpdHlQYXJzZXIgZnJvbSAnLi9lbnRpdHktcGFyc2VyJztcbmltcG9ydCBuYW1lZENoYXJSZWZzIGZyb20gJy4vaHRtbDUtbmFtZWQtY2hhci1yZWZzJztcblxuZXhwb3J0IGRlZmF1bHQgZnVuY3Rpb24gdG9rZW5pemUoaW5wdXQsIG9wdGlvbnMpIHtcbiAgbGV0IHRva2VuaXplciA9IG5ldyBUb2tlbml6ZXIobmV3IEVudGl0eVBhcnNlcihuYW1lZENoYXJSZWZzKSwgb3B0aW9ucyk7XG4gIHJldHVybiB0b2tlbml6ZXIudG9rZW5pemUoaW5wdXQpO1xufVxuIl19