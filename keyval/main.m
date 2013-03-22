#import <Foundation/Foundation.h>
#import <Foundation/NSMapTable.h>
#import <MLFoundation/MLTCPAcceptor.h>
#import <MLFoundation/EVBindings/EVLaterWatcher.h>
#import <MLFoundation/MLObject/MLObject.h>
#import <MLFoundation/MLCore/MLCategories.h>
#import "kvAcceptDelegator.h"

NSMapTable * g_map;

int main (int argc, const char * argv[])
{
  initMLCategories();
  g_map = [NSMapTable mapTableWithStrongToStrongObjects];
  EVLoop * lp = [[EVLoop alloc] init];
  MLTCPAcceptor * srv = [[MLTCPAcceptor alloc] init];
  kvAcceptDelegator * dlg = [[kvAcceptDelegator alloc] init];
  EVIoWatcher * w = [[EVIoWatcher alloc] init];
  [srv setLoop: lp];
  [srv setDelegate: dlg];
  [srv setPort: 9090];
  NSError * err = /*[[NSError alloc]*/ [NSError errorWithDomain:@"myDomain"
				code:0 
				localizedDescriptionFormat:@"Failed: %s", @"111"];
  NSLog([srv validateForStart:&err] == YES ? @"YES" : @"NO");
  [srv start];
  [lp run];

  return 0;
}

