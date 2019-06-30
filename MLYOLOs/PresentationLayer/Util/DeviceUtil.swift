//
//  DeviceUtil.swift
//  MLYOLOs
//
//  Created by 菊池達也 on 2019/06/30.
//  Copyright © 2019 菊池達也. All rights reserved.
//

import AVFoundation

final class DeviceUtil: NSObject {

    static func getDevice(_ frontCamera: Bool) -> AVCaptureDevice! {
        let position: AVCaptureDevice.Position = frontCamera ? .front : .back
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
            mediaType: AVMediaType.video,
            position: AVCaptureDevice.Position.unspecified
        )
        let devices = deviceDiscoverySession.devices
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
}
