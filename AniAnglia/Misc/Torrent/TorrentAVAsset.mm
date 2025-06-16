//
//  TorrentAVAsset.m
//  AniAnglia
//
//  Created by Toilettrauma on 06.02.2025.
//

#import <Foundation/Foundation.h>
#import "TorrentAVAsset.h"
#import "StringCvt.h"

#import <torrentrepo/TorrentSession.hpp>

@interface TorrentResourceLoaderURL ()

@end

struct ResourceLoaderDelegateItem {
    AVAssetResourceLoadingRequest* request;
    std::weak_ptr<torrentrepo::TorrentItem> torrent_item;
    std::vector<std::weak_ptr<torrentrepo::TorrentFile>> files;
};

@interface TorrentAVResourceLoaderDelegate () {
    // TODO: mutex = no race conditions
//    libtorrentrepo::TorrentSession _session;
    std::vector<ResourceLoaderDelegateItem> _requests;
}
@end

@implementation TorrentResourceLoaderURL
-(instancetype)init {
    self = [super init];
    
    _file_index = 0;
    
    return self;
}

@end

@implementation TorrentAVResourceLoaderDelegate

std::unique_ptr<torrentrepo::TorrentSession> session = nullptr;

-(instancetype)init {
    self = [super init];
    
    return self;
}

-(ResourceLoaderDelegateItem)findItemByRequest:(AVAssetResourceLoadingRequest*)loading_request {
    for (auto& item : _requests) {
        if ([loading_request isEqual:item.request]) {
            return item;
        }
    }
    return ResourceLoaderDelegateItem();
}

-(void)asyncCreateRequest:(AVAssetResourceLoadingRequest*)loading_request {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray* doc_paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* doc_path = [doc_paths firstObject];
        NSString* save_path = [NSString stringWithFormat:@"%@/torrentrepo_downloads/", doc_path];
        
        // If scheme correct -> this is actually an TorrentResourceLoaderURL
        TorrentResourceLoaderURL* url = (TorrentResourceLoaderURL*)loading_request.request.URL;
        std::weak_ptr<torrentrepo::TorrentItem> torrent_item = session->add_torrent(TO_STDSTRING(url.absoluteString), TO_STDSTRING(save_path), {});
        ResourceLoaderDelegateItem item;
        item.request = loading_request;
        item.torrent_item = torrent_item;
    
        auto titem = torrent_item.lock();
        if (!titem) return;
        while (true) {
            try {
                item.files.push_back(titem->start_download(static_cast<torrentrepo::file_index_t>(2)));
                break;
            } catch(...) {
                
            }
        }
        self->_requests.push_back(item);
        
        loading_request.contentInformationRequest.contentType = @"video/mp4";
        loading_request.contentInformationRequest.contentLength = titem->files()[2].size;
        loading_request.contentInformationRequest.byteRangeAccessSupported = YES;
        
        [self requestHandleRead:loading_request];
//    });
}

-(void)requestHandleRead:(AVAssetResourceLoadingRequest*)loading_request {
    ResourceLoaderDelegateItem item = [self findItemByRequest:loading_request];
    std::shared_ptr<torrentrepo::TorrentFile> file = item.files[0].lock();
    if (!file) return;
    
    file->seek(loading_request.dataRequest.requestedOffset, std::ios::beg);
    std::streamsize size = loading_request.dataRequest.requestsAllDataToEndOfResource ? -1 : loading_request.dataRequest.requestedLength;
    std::string data_raw = file->read(size);
    NSData* data = [[NSData alloc] initWithBytes:data_raw.data() length:data_raw.length()];
    [loading_request.dataRequest respondWithData:data];
    [loading_request finishLoading];
}

-(void)asyncRequestHandleRead:(AVAssetResourceLoadingRequest*)loading_request {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self requestHandleRead:loading_request];
    });
}

-(void)asyncHandleRequest:(AVAssetResourceLoadingRequest*)loading_request {
    if (loading_request.contentInformationRequest) {
        if ([self findItemByRequest:loading_request].request == nil) {
            [self asyncCreateRequest:loading_request];
        }
        return;
    }
    [self asyncRequestHandleRead:loading_request];
}

-(BOOL)resourceLoader:(AVAssetResourceLoader*)resource_loader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest*)loading_request {
    if (session == nullptr) {
        session = std::make_unique<torrentrepo::TorrentSession>();
    }
    // TODO: error check

    NSLog(@"Request: %@", loading_request);
    // TODO: change to custom
    if (![loading_request.request.URL.scheme isEqualToString:@"magnet"]) {
        return NO;
    }
    [self asyncHandleRequest:loading_request];
    
    return YES;
}

-(void)resourceLoader:(AVAssetResourceLoader *)resource_loader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loading_request {
    ResourceLoaderDelegateItem item = [self findItemByRequest:loading_request];
    if (item.request == nil) {
        return;
    }
//    _session.remove_torrent(TO_STDSTRING(loading_request.request.URL.absoluteString));
}

@end
